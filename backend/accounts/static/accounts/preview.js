/* Canonical RGBA materials. Integer transform matches appearance_catalog.gd. */
function colorizePixels(pixels, part, palette, catalog) {
  if (part === 'body' || palette === catalog.defaults[part]) return pixels;
  const target = catalog.colors[palette], denominator = 256 * catalog.luminance[part];
  for (let i = 0; i < pixels.length; i += 4) {
    if (!pixels[i + 3]) continue;
    const light = 54 * pixels[i] + 183 * pixels[i + 1] + 19 * pixels[i + 2];
    for (let c = 0; c < 3; c++) pixels[i + c] = Math.min(255, Math.floor(light * target[c] / denominator));
  }
  return pixels;
}
function composePixels(config, row, column, texture) {
  const face='face_'+config.face, hair='hair_'+config.hair;
  const parts=row===1||row===6||row===7?['body','skin','lower','shoes','upper',hair+'_back',face,hair+'_front']:[hair+'_back','body','skin','lower','shoes','upper',face,hair+'_front'];
  const output = {data: new Uint8ClampedArray(64*64*4)};
    const rear = row===1||row===6||row===7;
    const body = texture('body', config.skin_palette);
    for(let y=0;y<64;y++) {
      const begin=((row*64+y)*320+column*64)*4;
      output.data.set(body.subarray(begin,begin+256),y*256);
    }
    for(const part of parts) {
      if(part==='body') continue;
      const palette=part==='skin'||part===face?config.skin_palette:part.startsWith('hair_')?config.hair_palette:part==='upper'?config.upper_palette:part==='lower'?config.lower_palette:config.shoe_palette;
      const pixels=texture(part,palette);
      for(let y=0;y<64;y++)for(let x=0;x<64;x++) {
        const source=((row*64+y)*320+column*64+x)*4, dest=(y*64+x)*4;
        if(!pixels[source+3])continue;
        if(part===hair+'_back'&&!rear&&output.data[dest+3])continue;
        output.data.set(pixels.subarray(source,source+4),dest);
      }
    }
  return output.data;
}
if (typeof module !== 'undefined') module.exports = {colorizePixels, composePixels};
if (typeof document !== 'undefined') (async () => {
  const canvas = document.querySelector('#preview'), context = canvas.getContext('2d');
  const form = document.querySelector('#creator'), status = document.querySelector('#preview-status');
  const base = JSON.parse(document.querySelector('#initial-appearance').textContent);
  let paletteData;
  const names = ['body','skin','face_plain','face_freckles','hair_short_back','hair_short_front','hair_tied_back','hair_tied_front','upper','lower','shoes'];
  const sources = {}, tinted = new Map(); let row = 0, walking = false, phase = 0;
  try {
    const response = await fetch('/parts/palettes.json', {cache:'no-store'});
    if (!response.ok) throw new Error('Palette catalog unavailable');
    paletteData = await response.json();
    await Promise.all(names.map(async name => {
      const img = new Image(); img.src = '/parts/' + name + '.png'; await img.decode();
      const buffer = document.createElement('canvas'); buffer.width=320; buffer.height=512;
      buffer.getContext('2d').drawImage(img,0,0); sources[name]=buffer;
    }));
  } catch (_) { status.textContent='No se pudo cargar la vista previa. Recarga para intentarlo de nuevo.'; document.querySelector('#create-button').disabled=true; return; }
  function texture(name, palette) {
    const key=name+':'+palette; if(tinted.has(key)) return tinted.get(key);
    const buffer=document.createElement('canvas'); buffer.width=320; buffer.height=512;
    const ctx=buffer.getContext('2d'); ctx.drawImage(sources[name],0,0);
    const data=ctx.getImageData(0,0,320,512);
    colorizePixels(data.data, name, palette, paletteData);
    tinted.set(key,data.data);return data.data;
  }
  function draw(){
    const config={...base};for(const key of Object.keys(base)){const el=form.elements.namedItem(key);if(el)config[key]=el.value;}
    context.clearRect(0,0,64,64);context.imageSmoothingEnabled=false;
    const output = context.createImageData(64,64);
    output.data.set(composePixels(config,row,walking?phase+1:0,texture));
    context.putImageData(output,0,0);
  }
  form.addEventListener('change',draw);
  document.querySelector('#turn').onclick=()=>{row=(row+1)%8;draw();};
  document.querySelector('#walk').onclick=event=>{walking=!walking;event.target.textContent=walking?'Detener':'Caminar';draw();};
  setInterval(()=>{if(walking){phase=(phase+1)%4;draw();}},125);
  status.textContent='Así se verá tu personaje';draw();
})();
