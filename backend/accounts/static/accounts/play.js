(() => {
  const frame=document.querySelector('#game'), notice=document.querySelector('#connection');
  const status=document.querySelector('#connection-status'), reconnect=document.querySelector('#reconnect');
  const auth=document.querySelector('#ticket-auth');
  let ready=false, pending=false, timer;
  const send=message=>frame.contentWindow.postMessage({channel:'dreamscape-account',...message},location.origin);
  function error(message){status.textContent=message;notice.hidden=false;reconnect.hidden=false;clearTimeout(timer);}
  async function connect(){
    if(!ready||pending)return;pending=true;notice.hidden=false;reconnect.hidden=true;status.textContent='Recuperando tu personaje…';
    try{
      const response=await fetch('/api/ticket/',{method:'POST',credentials:'same-origin',headers:{'X-CSRFToken':auth.elements.csrfmiddlewaretoken.value}});
      if(response.status===401){location.assign('/');return;}
      if(!response.ok)throw Error();const data=await response.json();send({type:'connect',...data});
      timer=setTimeout(()=>error('No se pudo conectar. Tu último guardado se conserva.'),15000);
    }catch(_){error('No se pudo conectar. Tu último guardado se conserva.');}finally{pending=false;}
  }
  window.addEventListener('message',event=>{
    if(event.origin!==location.origin||event.source!==frame.contentWindow||event.data?.channel!=='dreamscape-account')return;
    const message=event.data;
    if(message.type==='ready'){ready=true;connect();}
    if(message.type==='joined'||message.type==='saved'){
      clearTimeout(timer);notice.hidden=true;reconnect.hidden=true;
    }
    if(message.type==='error')error(message.error==='session_replaced'?'Esta cuenta se ha abierto en otra sesión.':'Conexión interrumpida. Se conserva el último guardado confirmado.');
  });
  reconnect.onclick=connect;
})();
