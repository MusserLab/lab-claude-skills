#!/usr/bin/env python3
"""Preview or apply one marker-bounded RESEARCH-CORE instruction block."""

from __future__ import annotations

import argparse
import difflib
import hashlib
import os
from pathlib import Path
import stat
import sys
import tempfile


BEGIN = b"<!-- BEGIN RESEARCH-CORE -->"
END = b"<!-- END RESEARCH-CORE -->"
BACKUP_SUFFIX = ".research-core.bak"


class InstallError(Exception):
    """A user-correctable validation or approval failure."""


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Preview or apply a RESEARCH-CORE instruction block.",
        epilog=(
            "The first changed existing target is backed up once as "
            "TARGET.research-core.bak; later writes preserve that backup."
        ),
    )
    parser.add_argument("--target", required=True, help="absolute instruction-file path")
    parser.add_argument("--source", help="Markdown body to install (markers are added)")
    parser.add_argument(
        "--remove", action="store_true", help="remove the managed block instead"
    )
    parser.add_argument("--apply", action="store_true", help="perform the previewed write")
    parser.add_argument("--approve", help="approval token printed by the preview")
    args = parser.parse_args(argv)

    if args.remove and args.source:
        parser.error("--source cannot be used with --remove")
    if not args.remove and not args.source:
        parser.error("--source is required unless --remove is used")
    if args.apply and not args.approve:
        parser.error("--apply requires --approve TOKEN")
    if args.approve and not args.apply:
        parser.error("--approve requires --apply")
    return args


def validated_target(raw_target: str) -> Path:
    target = Path(raw_target)
    if not target.is_absolute():
        raise InstallError("--target must be an absolute path")
    if target.is_symlink():
        raise InstallError(f"refusing symlink target: {target}")
    try:
        parent = target.parent.resolve(strict=True)
    except FileNotFoundError:
        raise InstallError(f"target parent directory does not exist: {target.parent}")
    target = parent / target.name
    if target.is_symlink():
        raise InstallError(f"refusing symlink target: {target}")
    if target.exists() and not target.is_file():
        raise InstallError(f"target is not a regular file: {target}")
    return target


def read_target(target: Path) -> tuple[bytes, int | None]:
    if not target.exists():
        return b"", None
    data = target.read_bytes()
    try:
        data.decode("utf-8")
    except UnicodeDecodeError as error:
        raise InstallError(f"target is not valid UTF-8 Markdown: {target}") from error
    return data, stat.S_IMODE(target.stat().st_mode)


def render_source(source: Path) -> bytes:
    if not source.is_file():
        raise InstallError(f"source is not a regular file: {source}")
    body = source.read_bytes()
    try:
        body.decode("utf-8")
    except UnicodeDecodeError as error:
        raise InstallError(f"source is not valid UTF-8 Markdown: {source}") from error
    if BEGIN in body or END in body:
        raise InstallError(
            "source must contain block body only; RESEARCH-CORE markers are added"
        )
    if not body.strip():
        raise InstallError("source Markdown is empty")
    if not body.endswith(b"\n"):
        body += b"\n"
    return BEGIN + b"\n" + body + END + b"\n"


def managed_span(data: bytes) -> tuple[int, int] | None:
    begin_count = data.count(BEGIN)
    end_count = data.count(END)
    if begin_count == 0 and end_count == 0:
        return None
    if begin_count != 1 or end_count != 1:
        raise InstallError("malformed RESEARCH-CORE markers: expected one matched pair")

    start = data.index(BEGIN)
    end_start = data.index(END)
    if end_start <= start:
        raise InstallError("malformed RESEARCH-CORE markers: end precedes begin")
    if start and data[start - 1 : start] != b"\n":
        raise InstallError("malformed RESEARCH-CORE markers: begin is not on its own line")

    after_begin = start + len(BEGIN)
    if data[after_begin : after_begin + 2] == b"\r\n":
        pass
    elif data[after_begin : after_begin + 1] != b"\n":
        raise InstallError("malformed RESEARCH-CORE markers: begin line is incomplete")
    if data[end_start - 1 : end_start] != b"\n":
        raise InstallError("malformed RESEARCH-CORE markers: end is not on its own line")

    end = end_start + len(END)
    if data[end : end + 2] == b"\r\n":
        end += 2
    elif data[end : end + 1] == b"\n":
        end += 1
    elif end != len(data):
        raise InstallError("malformed RESEARCH-CORE markers: end line is incomplete")
    return start, end


def proposed_bytes(before: bytes, source_block: bytes | None, remove: bool) -> bytes:
    span = managed_span(before)
    if remove:
        if span is None:
            return before
        return before[: span[0]] + before[span[1] :]
    assert source_block is not None
    if span is None:
        return source_block + before
    return before[: span[0]] + source_block + before[span[1] :]


def approval_token(target: Path, before: bytes, after: bytes) -> str:
    digest = hashlib.sha256()
    digest.update(b"research-core-instructions-v1\0")
    for value in (os.fsencode(str(target)), before, after):
        digest.update(len(value).to_bytes(8, "big"))
        digest.update(value)
    return digest.hexdigest()


def print_preview(target: Path, before: bytes, after: bytes, token: str) -> None:
    print(f"Target: {target}")
    print("Diff:")
    if before == after:
        print("(no changes)")
    else:
        before_text = before.decode("utf-8").splitlines(keepends=True)
        after_text = after.decode("utf-8").splitlines(keepends=True)
        diff = difflib.unified_diff(
            before_text,
            after_text,
            fromfile=f"before:{target}",
            tofile=f"after:{target}",
        )
        rendered = "".join(diff)
        sys.stdout.write(rendered)
        if rendered and not rendered.endswith("\n"):
            print()
    print(f"Approval token: {token}")


def create_backup_once(target: Path, before: bytes, mode: int) -> tuple[Path, bool]:
    backup = target.with_name(target.name + BACKUP_SUFFIX)
    if os.path.lexists(backup):
        if backup.is_symlink() or not backup.is_file():
            raise InstallError(f"backup path is not a regular file: {backup}")
        return backup, False
    try:
        descriptor = os.open(backup, os.O_WRONLY | os.O_CREAT | os.O_EXCL, mode)
    except FileExistsError:
        if backup.is_symlink() or not backup.is_file():
            raise InstallError(f"backup path is not a regular file: {backup}")
        return backup, False
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(before)
            handle.flush()
            os.fsync(handle.fileno())
    except Exception:
        backup.unlink(missing_ok=True)
        raise
    return backup, True


def atomic_write(target: Path, content: bytes, mode: int | None) -> None:
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{target.name}.research-core-", suffix=".tmp", dir=target.parent
    )
    temporary = Path(temporary_name)
    try:
        os.fchmod(descriptor, 0o644 if mode is None else mode)
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, target)
        directory_fd = os.open(target.parent, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    except Exception:
        temporary.unlink(missing_ok=True)
        raise


def run(args: argparse.Namespace) -> int:
    target = validated_target(args.target)
    source_block = None if args.remove else render_source(Path(args.source))
    before, mode = read_target(target)
    after = proposed_bytes(before, source_block, args.remove)
    token = approval_token(target, before, after)

    if not args.apply:
        print_preview(target, before, after, token)
        return 0
    if args.approve != token:
        raise InstallError(
            "approval token does not match current target/source bytes; preview again"
        )
    if before == after:
        print(f"Target: {target}")
        print("No change; nothing written.")
        return 0

    current, current_mode = read_target(target)
    if current != before or current_mode != mode:
        raise InstallError("target changed after validation; preview again")

    backup: tuple[Path, bool] | None = None
    if mode is not None:
        backup = create_backup_once(target, before, mode)
    atomic_write(target, after, mode)

    print(f"Target: {target}")
    print("Applied RESEARCH-CORE block removal." if args.remove else "Applied RESEARCH-CORE block.")
    if backup:
        path, created = backup
        status = "created from first changed existing target" if created else "first backup preserved"
        print(f"Backup: {path} ({status})")
    return 0


def main(argv: list[str] | None = None) -> int:
    try:
        return run(parse_args(argv))
    except InstallError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    except OSError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
