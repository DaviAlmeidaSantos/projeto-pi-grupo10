// importa os bibliotecas necessários
const serialport = require('serialport');
const express = require('express');
const mysql = require('mysql2');
const path = require('path');
const { exec } = require('child_process');

// constantes para configurações
const SERIAL_BAUD_RATE = 9600;
const SERVIDOR_PORTA = 3300;

// habilita ou desabilita a inserção de dados no banco de dados
const HABILITAR_OPERACAO_INSERIR = true;

// função para comunicação serial
const serial = async (
    valoresHCSR04
) => {

    // conexão com o banco de dados MySQL
    let poolBancoDados = mysql.createPool(
        {
            host: 'localhost',
            user: 'Insu',
            password: 'Insu100#',
            database: 'insumais',
            port: 3307
        }
    ).promise();

    // lista as portas seriais disponíveis e procura pelo Arduino
    const portas = await serialport.SerialPort.list();
    const portaArduino = portas.find((porta) => porta.vendorId == 2341 && porta.productId == 43);
    if (!portaArduino) {
        throw new Error('O arduino não foi encontrado em nenhuma porta serial');
    }

    // configura a porta serial com o baud rate especificado
    const arduino = new serialport.SerialPort(
        {
            path: portaArduino.path,
            baudRate: SERIAL_BAUD_RATE
        }
    );

    // evento quando a porta serial é aberta
    arduino.on('open', () => {
        console.log(`A leitura do arduino foi iniciada na porta ${portaArduino.path} utilizando Baud Rate de ${SERIAL_BAUD_RATE}`);
    });

    // processa os dados recebidos do Arduino
    arduino.pipe(new serialport.ReadlineParser({ delimiter: '\r\n' })).on('data', async (data) => {
        console.log(data);
        const valores = data.split(';');
        const distancia = parseInt(valores[0]);

        // armazena os valores dos sensores nos arrays correspondentes
        valoresHCSR04.push(distancia);

        // insere os dados no banco de dados (se habilitado)
        if (HABILITAR_OPERACAO_INSERIR) {
            // este insert irá inserir o valor de distancia na tabela "val_sensor"
            await poolBancoDados.execute(
                'INSERT INTO sensor (medicao) VALUES (?)',
                [distancia]
            );
            console.log("valores inseridos no banco: ", +distancia);
        }

    });

    // evento para lidar com erros na comunicação serial
    arduino.on('error', (mensagem) => {
        console.error(`Erro no arduino (Mensagem: ${mensagem}`)
    });
}

// função para criar e configurar o servidor web
const servidor = (
    valoresHCSR04
) => {
    const app = express();

    // expõe arquivos estáticos (permite acessar indexv2.html diretamente)
    app.use(express.static(path.join(__dirname)));

    // configurações de requisição e resposta
    app.use((request, response, next) => {
        response.header('Access-Control-Allow-Origin', '*');
        response.header('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');
        next();
    });

    // rota raiz serve index.html (indexv2.html não existe no projeto)
    app.get('/', (_, res) => {
        res.sendFile(path.join(__dirname, 'index.html'));
    });

    // inicia o servidor na porta especificada e trata erros comuns (ex: EADDRINUSE)
    const serverInstance = app.listen(SERVIDOR_PORTA, () => {
        console.log(`API executada com sucesso na porta ${SERVIDOR_PORTA}`);

        // tenta abrir o navegador padrão na raiz da aplicação
        const url = `http://localhost:${SERVIDOR_PORTA}`;
        (function openBrowser(u) {
            const platform = process.platform;
            let cmd;
            if (platform === 'win32') cmd = `start "" "${u}"`;
            else if (platform === 'darwin') cmd = `open "${u}"`;
            else cmd = `xdg-open "${u}"`;

            exec(cmd, (error) => {
                if (error) {
                    // não falha a aplicação se não conseguir abrir o navegador
                    console.warn('Não foi possível abrir o navegador automaticamente:', error.message || error);
                }
            });
        })(url);
    });

    serverInstance.on('error', (err) => {
        if (err && err.code === 'EADDRINUSE') {
            console.error(`Porta ${SERVIDOR_PORTA} já está em uso. Finalize o processo que a está usando ou altere a porta.`);
            // encerra com código de erro para sinalizar o problema
            process.exit(1);
        }
        console.error('Erro no servidor:', err);
    });

    // define os endpoints da API para cada tipo de sensor
    app.get('/sensores/digital', (_, response) => {
        return response.json(valoresHCSR04);
    });
}

// função principal assíncrona para iniciar a comunicação serial e o servidor web
// função principal assíncrona para iniciar a aplicação
(() => {
    // arrays para armazenar os valores dos sensores
    const valoresHCSR04 = [];

    // inicia o servidor web primeiro para garantir que a UI carregue
    servidor(
        valoresHCSR04
    );

    // inicia a comunicação serial em background. Se ocorrer erro
    // na inicialização da serial, logamos e deixamos a API funcionando
    serial(
        valoresHCSR04
    ).catch((err) => {
        console.error('Erro ao inicializar serial:', err && err.message ? err.message : err);
    });
})();
