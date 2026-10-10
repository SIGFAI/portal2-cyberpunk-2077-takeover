from PIL import Image
import glob, sys
n=int(sys.argv[1]) if len(sys.argv)>1 else 5
fs=sorted(glob.glob('C:/Games/portal2/sigf/screenshots/*.jpg'))[-n:]
cols=3
c=Image.new('RGB',(1280,240*((n+2)//3)))
for i,f in enumerate(fs):
    im=Image.open(f).resize((426,240)); c.paste(im,((i%cols)*427,(i//cols)*241))
c.save('gen/scout.png')
