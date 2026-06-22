#!/usr/bin/env python
"""
render_pipeline.py — draw an analysis pipeline from a small YAML spec.

  python render_pipeline.py <spec.yaml> <out_prefix> [--detail]

Produces <out_prefix>.png + .pdf (the flowing-backbone OVERVIEW). With --detail it
also writes <out_prefix>_detail.png/.pdf — one card per step showing the exact
input files -> operation/params -> output files.

Spec schema (see pipeline_spec.example.yaml):
  title: str
  subtitle: str
  theme: optional {line,blue,...} colour overrides
  steps:                       # ordered, top -> bottom
    - title: str               # step name (bold, overview)
      decision: str            # the key decision / note (blue annotation)
      inputs:  [{label: str, kind: required|optional}]   # overview, left
      outputs: [{label: str, file: str, terminal: bool}] # overview, right
      script:   str            # detail header
      files_in:  [str]         # detail
      files_out: [str]         # detail
      params:    [str]         # detail bullets (params / decisions)

Requires: pyyaml, matplotlib.
"""
import sys, yaml
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

THEME=dict(line='#b3a878', blue='#3f7fa6', dark='#2b2b2b', grey='#8a8a8a',
           req='#8f8059', opt='#cabd92', step='#dcd4b4', out='#b5651d', term='#7a3b8f',
           legendbg='#efe9d4')

def _spread(target_ys, gap, top):
    """Greedy: keep items near their target y but push down to avoid collisions."""
    order=sorted(range(len(target_ys)), key=lambda i:-target_ys[i])
    ys=[0.0]*len(target_ys); last=top+gap
    for i in order:
        y=min(target_ys[i], last-gap); ys[i]=y; last=y
    return ys

def overview(spec, out_prefix):
    T=THEME.copy(); T.update(spec.get('theme',{}))
    steps=spec['steps']; n=len(steps)
    TOP, BOT = 1.0*n+1, 1.0
    sy=[TOP - i*(TOP-BOT)/max(n-1,1) for i in range(n)]
    BBX, INX, OUTX = 4.0, 1.7, 10.0

    # gather inputs / outputs with their target step y
    ins=[]; outs=[]
    for i,s in enumerate(steps):
        for it in s.get('inputs',[]) or []: ins.append((it['label'], it.get('kind','optional'), sy[i]))
        for ot in s.get('outputs',[]) or []: outs.append((ot['label'], ot.get('file',''), ot.get('terminal',False), sy[i]))
    iy=_spread([t for *_,t in ins], 0.9, TOP+0.4) if ins else []
    oy=_spread([t for *_,t in outs], 0.9, TOP+0.4) if outs else []

    fig,ax=plt.subplots(figsize=(14, max(7, 1.35*n+2)))
    ax.set_xlim(0,13); ax.set_ylim(min(BOT, (min(oy+iy+[BOT]))-0.6), TOP+1.4); ax.set_aspect('auto'); ax.axis('off')
    ax.plot([BBX]*n, sy, color=T['line'], lw=3.2, zorder=1, solid_capstyle='round')

    def curve(p1,p2,rad,lw=2.2):
        ax.add_patch(FancyArrowPatch(p1,p2,connectionstyle=f'arc3,rad={rad}',arrowstyle='-',
                     color=T['line'],lw=lw,zorder=1,shrinkA=10,shrinkB=10,capstyle='round'))
    def clamp(v,a,b): return max(a,min(b,v))

    for (lab,kind,ty),y in zip(ins,iy):
        curve((INX,y),(BBX,ty),clamp(0.16*(y-ty),-0.30,0.30))
        ax.scatter([INX],[y],s=430,facecolor=T['req'] if kind=='required' else T['opt'],
                   edgecolor='#6f6443',linewidth=1.6,linestyle='solid' if kind=='required' else (0,(2,2)),zorder=4)
        ax.text(INX-0.28,y,lab,ha='right',va='center',fontsize=9,color=T['dark'])
    for i,s in enumerate(steps):
        y=sy[i]
        ax.scatter([BBX],[y],s=540,facecolor=T['step'],edgecolor=T['line'],linewidth=1.8,zorder=4)
        ax.text(BBX+0.34,y+0.12,s['title'],ha='left',va='center',fontsize=12.5,color=T['dark'],fontweight='bold')
        if s.get('decision'):
            ax.text(BBX+0.34,y-0.28,s['decision'],ha='left',va='top',fontsize=8.6,color=T['blue'],style='italic')
    for (lab,fname,term,ty),y in zip(outs,oy):
        curve((BBX,ty),(OUTX,y),clamp(0.16*(y-ty),-0.30,0.30))
        ax.scatter([OUTX],[y],s=470,facecolor=T['term'] if term else T['out'],
                   edgecolor='#43215a' if term else '#5e3a16',linewidth=1.6,zorder=4)
        ax.text(OUTX+0.28,y+0.12,lab,ha='left',va='center',fontsize=9.2,color=T['dark'],fontweight='bold')
        if fname: ax.text(OUTX+0.28,y-0.16,fname,ha='left',va='center',fontsize=7.4,color=T['grey'],family='monospace')

    # legend (only kinds present)
    have_req=any(k=='required' for _,k,_ in ins); have_opt=any(k!='required' for _,k,_ in ins)
    have_term=any(t for *_,t,_ in [(o[0],o[1],o[2],o[3]) for o in outs])
    items=[]
    if have_req: items.append(('required input',T['req'],'solid'))
    if have_opt: items.append(('optional input',T['opt'],(0,(2,2))))
    items.append(('pipeline step',T['step'],'solid')); items.append(('output file',T['out'],'solid'))
    if have_term: items.append(('terminal / queryable',T['term'],'solid'))
    lx=0.1; lh=0.05+0.33*len(items); ly=ax.get_ylim()[0]+0.15
    ax.add_patch(FancyBboxPatch((lx,ly),3.0,lh,boxstyle='round,pad=0.04,rounding_size=0.06',fc=T['legendbg'],ec=T['line'],lw=1.0,zorder=3))
    for i,(lab,c,ls) in enumerate(items):
        yy=ly+lh-0.25-i*0.30
        ax.scatter([lx+0.32],[yy],s=170,facecolor=c,edgecolor='#6f6443',linewidth=1.2,linestyle=ls,zorder=5)
        ax.text(lx+0.62,yy,lab,ha='left',va='center',fontsize=8.6,color=T['dark'],zorder=5)

    ax.text(0.1,TOP+1.15,spec.get('title',''),fontsize=16,fontweight='bold',color=T['dark'])
    if spec.get('subtitle'): ax.text(0.1,TOP+0.82,spec['subtitle'],fontsize=9.5,color=T['blue'],style='italic')
    fig.savefig(f'{out_prefix}.pdf',bbox_inches='tight'); fig.savefig(f'{out_prefix}.png',dpi=200,bbox_inches='tight')
    plt.close(fig); print(f'wrote {out_prefix}.png/.pdf')

def detail(spec, out_prefix):
    """One card per step: top row = input files | output files; lower = key decisions."""
    T=THEME.copy(); T.update(spec.get('theme',{}))
    steps=[s for s in spec['steps'] if s.get('files_in') or s.get('files_out') or s.get('params') or s.get('script')]
    n=len(steps); PITCH=2.2; H=1.95
    fig,ax=plt.subplots(figsize=(13, PITCH*n+1)); ax.axis('off')
    ax.set_xlim(0,13); ax.set_ylim(0, PITCH*n+0.5)
    for i,s in enumerate(steps):
        y=PITCH*n-0.5-i*PITCH
        ax.add_patch(FancyBboxPatch((0.3,y-H+0.15),12.4,H,boxstyle='round,pad=0.03,rounding_size=0.05',
                     fc='#faf8f0',ec=T['line'],lw=1.3,zorder=1))
        ax.add_patch(FancyBboxPatch((0.3,y-0.05),12.4,0.42,boxstyle='round,pad=0.02,rounding_size=0.05',
                     fc=T['step'],ec=T['line'],lw=1.0,zorder=2))
        ax.text(0.5,y+0.16,f"{i+1}.  {s['title']}",ha='left',va='center',fontsize=12,fontweight='bold',color=T['dark'],zorder=3)
        if s.get('script'): ax.text(12.5,y+0.16,s['script'],ha='right',va='center',fontsize=8.5,color=T['grey'],family='monospace',zorder=3)
        # row 1: input files (left half) | output files (right half)
        ax.text(0.5,y-0.16,'in:',ha='left',va='top',fontsize=8,color=T['dark'],fontweight='bold')
        ax.text(0.95,y-0.16,'\n'.join(s.get('files_in',[]) or ['—']),ha='left',va='top',fontsize=7.2,color=T['grey'],family='monospace')
        ax.text(6.7,y-0.16,'out:',ha='left',va='top',fontsize=8,color=T['dark'],fontweight='bold')
        ax.text(7.2,y-0.16,'\n'.join(s.get('files_out',[]) or ['—']),ha='left',va='top',fontsize=7.2,color=T['out'],family='monospace')
        # row 2: key decisions / params (full width, below)
        if s.get('params'):
            ax.text(0.5,y-H+0.62,'key:',ha='left',va='top',fontsize=8,color=T['dark'],fontweight='bold')
            ax.text(0.95,y-H+0.62,'   '.join('• '+p for p in s['params']),ha='left',va='top',fontsize=8,color=T['blue'],style='italic')
    ax.text(0.3,PITCH*n+0.25,(spec.get('title','')+'  —  per-step detail'),fontsize=14,fontweight='bold',color=T['dark'])
    fig.savefig(f'{out_prefix}_detail.pdf',bbox_inches='tight'); fig.savefig(f'{out_prefix}_detail.png',dpi=200,bbox_inches='tight')
    plt.close(fig); print(f'wrote {out_prefix}_detail.png/.pdf')

if __name__=='__main__':
    if len(sys.argv)<3: print(__doc__); sys.exit(1)
    spec=yaml.safe_load(open(sys.argv[1]))
    overview(spec, sys.argv[2])
    if '--detail' in sys.argv: detail(spec, sys.argv[2])
