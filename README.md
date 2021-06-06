# kstrosmkpppoe
Script para atualizar gateway de links pppoe em RouterOS

## Apresentação:
  
Este script foi criado com objetivo de automatizar a mudança de gateway para interfaces PPPoE, quando o administrador usa o recurso de check-gateway para rotas default que usam o recurso de recursividade.
    
## O script:

O script **kstrosmkpppoe** possui variáveis de controle listadas abaixo:

**InterfacePppoe** -> Recebe o noma da interface PPPoE *(deve ser informado entre aspas)*<br>
**TargetPing** -> Recebe o IP de destino no qual será ativado o checkgateway *(deve ser informado entre aspas)*<br>
**DistanceGateway** -> Recebe o distance para a rota default [int]<br>

**CriaRotaDefault** -> Informa se a rota default será criada ou não [true | false]<br>
**EnableScript** -> Habilita a execução do script [true | false]<br>

Caso o administrador necessite acompanhar visualmente as mensagens emitidas pelo script deve habilitar a emissão de logs **SYSTEM -> Logging -> Rules** com o tópico "script,debug", pois as mensagens de informação somente serão exibidas em modo de debug.

## Compatibilidade:

O script foi homologado para a versão 6.47.9 ou posterior do RouterOS.

## Como usar:



Primeiramente deve ser baixado uma cópia do script [**kstrosmkpppoe**](https://github.com/jayroncastro/kstrosmkpppoe/blob/master/kstrosmkpppoe.rsc) e armazenado em **SYSTEM -> Scripts**, o administrador deve criar qualquer nome para o novo script, mas deve tomar nota pois esse nome será usado em posterior.

Após criar o script o administrador deverá alterar as variáveis de controle conforme sua necessidade.

Nesse ponto será necessário criar um novo profile em **PPP -> Profiles** e na aba **Scripts** deverá ser informado o nome do script criado anteriormente, tanto na opção **On Up** como na opção **On Down**.

Agora será necessário abrir a interface PPPoE a ser monitorada em **PPP -> Interface** e na aba **Dial Out** duas alterações deverão ser feitas, sendo:

1. Selecionar o **Profile** criado anteriormente;
2. Desabilitar a opção **Add Default Route**.

Feitas as modificações necessárias deve-se aplicar e fechar a tela de edição da interface.

## Execução

Para testar o funcionamento deve-se desativar e ativar a interface, será percebido na tabela de roteamento que duas rotas serão criadas, a primeira rota terá o endereço de destino fornecido na variável **TargetPing** com o gateway da interface PPPoE monitorada e tendo seu escopo com o valor 10.

Será criada uma segunda rota do tipo **Default** com o gateway **TargetPing** e habilitado a opção **check-gateway** como ping.

Com essas duas rotas criadas, caso o IP monitorado via **TargetPing** não responda em até 10s o RouterOS desabilita a rota.

## Indicação

O uso desse script é recomendado em cenários que usam mais de um link, pois caso o link principal se torne off-line o tráfego será direcionado para o link de backup.

## Contato

Caso seja encontrato algum erro de execução no script ou mesmo para melhorias, favor informar o desenvolvedor pelo e-mail jacastro@kstros.com para que as correções ou melhorias sejam aplicadas.
