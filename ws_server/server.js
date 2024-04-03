const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

var currentServeId = -1;
var wsList = {}

function getOnServeId(){
    currentServeId = currentServeId + 1; 
    return currentServeId;
}




wss.on('connection', function connection(ws) {
    
    var onServeId = getOnServeId();
    var oponente = null;
    var battle_read = false;
    var gridData;
    var currentHit;

    wsList[onServeId] = ws;

    console.log('Cliente '+ onServeId +' se conectou');
    
    
    freeMach(ws)    
    
    ws.on('message', function incoming(message) {
        
        tratarJson(ws,JSON.parse(message));
        
    });

    ws.on('close', function close() {

        if(ws.oponente != undefined){
            ws.oponente.send(preFabJason('dc', ws.onServeId));
        }
        
        console.log('Cliente '+ onServeId +' se desconectou');

    });
    
});

function freeMach(ws){

    wss.clients.forEach(function each(valor) {
        if (valor != ws  && valor.oponente == null){
            ws.oponente = valor;
            valor.oponente = ws;
            valor.send(preFabJason('start', ws.onServeId));
            ws.send(preFabJason('start',  valor.onServeId));
            console.log("Partida encotrada!");
            return;
        }
    
    })

}

function preFabJason(status,data){
    var json = {
        type:'update',
        round_status:status,
        subject:'',
        data:data
    };
    return JSON.stringify(json)

}

function tratarJson(ws,m){

    switch(m.type) {
    
        case "send":
            console.log("send")
            m.typer = "result";

            if(m.subject == "hit"){
                ws.currentHit = m;
                console.log("hit");
            }
            else{
                ws.gridData = m;
            }
            ws.battle_read = true
            break;
        
        case "request":
            
            if(ws.oponente == null)
                break;
            console.log("request");

            if(ws.battle_read && ws.oponente.battle_read){
                
                if(m.subject == "hit"){
                    console.log("hit");
                    console.log(ws.currentHit);
                    ws.oponente.currentHit.round_status = "on";
                    ws.currentHit.round_status = "on";

                    ws.send(JSON.stringify(ws.oponente.currentHit));
                    ws.oponente.send(JSON.stringify(ws.currentHit));
                }

                else{
                    ws.oponente.gridData.subject = "grid";
                    ws.gridData.subject = "grid";
                    ws.send(JSON.stringify(ws.oponente.gridData));
                    ws.oponente.send(JSON.stringify(ws.gridData));
                }

                ws.battle_read = false;
                ws.oponente.battle_read = false;
            }

            break;
        
        default:

    } 

}
