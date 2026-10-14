/* Compose the same indexed parts/pose order as the Godot appearance catalog. */
(async () => {
  const canvas = document.querySelector('#preview'), context = canvas.getContext('2d');
  const form = document.querySelector('#creator'), status = document.querySelector('#preview-status');
  const base = JSON.parse(document.querySelector('#initial-appearance').textContent);
  const palettes = {
    warm:['211e25','a36549','d99a6b','f0c291'],olive:['211e25','8a6649','bb9567','dbb886'],deep:['211e25','573a32','875c43','b6835f'],
    chestnut:['211e25','613e32','8e593c','b78150'],ink:['211e25','30303a','49464a','68616a'],
    teal:['211e25','315b60','42858a','73a9a0'],ochre:['211e25','856035','b58b47','d8b968'],
    charcoal:['211e25','373641','53515b','77717b'],earth:['211e25','51493e','756b51','9d9270'],leather:['211e25','544539','82684f','c0ae8c']};
  const names = ['body','face_plain','face_freckles','hair_short_back','hair_short_front','hair_tied_back','hair_tied_front','upper','lower','shoes'];
  const sources = {}, tinted = new Map(); let row = 0, walking = false, phase = 0;
  try {
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
    for(let i=0;i<data.data.length;i+=4){
      const p=data.data;if(p[i+3]<128)continue;
      const shade=p[i]===33&&p[i+1]===30&&p[i+2]===37?0:p[i]<128?1:p[i]<230?2:3;
      const color=palettes[palette][shade];for(let c=0;c<3;c++)p[i+c]=parseInt(color.slice(c*2,c*2+2),16);
    }
    ctx.putImageData(data,0,0);tinted.set(key,buffer);return buffer;
  }
  function draw(){
    const config={...base};for(const key of Object.keys(base)){const el=form.elements.namedItem(key);if(el)config[key]=el.value;}
    const face='face_'+config.face,hair='hair_'+config.hair;
    const parts=row===1||row===6||row===7?['body','lower','shoes','upper',hair+'_back',face,hair+'_front']:[hair+'_back','body','lower','shoes','upper',face,hair+'_front'];
    context.clearRect(0,0,64,64);context.imageSmoothingEnabled=false;
    for(const part of parts){const palette=part==='body'||part===face?config.skin_palette:part.startsWith('hair_')?config.hair_palette:part==='upper'?config.upper_palette:part==='lower'?config.lower_palette:config.shoe_palette;context.drawImage(texture(part,palette),(walking?phase+1:0)*64,row*64,64,64,0,0,64,64);}
  }
  form.addEventListener('change',draw);
  document.querySelector('#turn').onclick=()=>{row=(row+1)%8;draw();};
  document.querySelector('#walk').onclick=event=>{walking=!walking;event.target.textContent=walking?'Detener':'Caminar';draw();};
  setInterval(()=>{if(walking){phase=(phase+1)%4;draw();}},125);
  status.textContent='Así se verá tu personaje';draw();
})();
