(() => {
  const frame=document.querySelector('#game'), status=document.querySelector('#save-status');
  const reconnect=document.querySelector('#reconnect'), logout=document.querySelector('#logout'), customize=document.querySelector('#customize');
  const exits=[logout,customize];
  let ready=false, connected=false, pending=false, leaving=null, timer;
  const send=message=>frame.contentWindow.postMessage({channel:'dreamscape-account',...message},location.origin);
  function error(message){status.textContent=message;status.className='error';reconnect.hidden=false;connected=false;leaving=null;exits.forEach(form=>form.querySelector('button').disabled=false);clearTimeout(timer);}
  async function connect(){
    if(!ready||pending)return;pending=true;reconnect.hidden=true;status.className='';status.textContent='Recuperando tu personaje…';
    try{
      const response=await fetch('/api/ticket/',{method:'POST',credentials:'same-origin',headers:{'X-CSRFToken':logout.elements.csrfmiddlewaretoken.value}});
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
      connected=true;if(!leaving)clearTimeout(timer);status.className='';reconnect.hidden=true;
      status.textContent='Guardado · '+new Date(message.saved_at).toLocaleTimeString([], {hour:'2-digit',minute:'2-digit',second:'2-digit'});
    }
    if(message.type==='left'&&leaving){clearTimeout(timer);HTMLFormElement.prototype.submit.call(leaving);}
    if(message.type==='error')error(message.error==='session_replaced'?'Esta cuenta se ha abierto en otra sesión.':'Conexión interrumpida. Se conserva el último guardado confirmado.');
  });
  reconnect.onclick=connect;
  exits.forEach(form=>form.addEventListener('submit',event=>{
    if(!connected)return;event.preventDefault();if(leaving)return;
    leaving=form;exits.forEach(exit=>exit.querySelector('button').disabled=true);status.textContent='Guardando antes de salir…';send({type:'leave'});
    timer=setTimeout(()=>error('No se pudo confirmar el guardado. Reconecta o cierra sesión conservando el último confirmado.'),10000);
  }));
})();
