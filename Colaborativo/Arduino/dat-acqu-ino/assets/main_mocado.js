
const express = require('express');
const path = require('path');

const SERVIDOR_PORTA = 3300;

const valoresSensorAnalogico = [];
const valoresSensorDistancia = [];

const app = express();

app.use(express.static(path.join(__dirname)));

app.get('/', (_, res) => {
    res.sendFile(path.join(__dirname, 'index_mocado.html'));
});

app.use((request, response, next) => {
    response.header('Access-Control-Allow-Origin', '*');
    response.header('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');
    next();
});

app.get('/sensores/analogico', (_, response) => {
    return response.json(valoresSensorAnalogico);
});

app.get('/sensores/digital', (_, response) => {
    return response.json(valoresSensorDistancia);
});

setInterval(() => {
    const distancia = Math.floor(Math.random() * 100) + 1;
    const sensorAnalogico = Math.floor(Math.random() * 1024);

    valoresSensorAnalogico.push(sensorAnalogico);
    valoresSensorDistancia.push(distancia);

    if (valoresSensorAnalogico.length > 50) {
        valoresSensorAnalogico.shift();
        valoresSensorDistancia.shift();
    }

    console.log(`Distância: ${distancia} | Analógico: ${sensorAnalogico}`);

}, 1000);

app.listen(SERVIDOR_PORTA, () => {
    console.log(`API simulada executada na porta ${SERVIDOR_PORTA}`);
    console.log('Dashboard: http://localhost:3300');
});
