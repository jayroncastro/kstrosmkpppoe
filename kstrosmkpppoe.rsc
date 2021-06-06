#kstrosmkpppoe
#Script para atualizar gateway de links pppoe em RouterOS
#Feito por: Jayron Castro
#Data: 05/06/2021 10:12
#e-Mail: jacastro@kstros.com
#Versao: 1.0
{

    #===============================================
    #DEFINIÇÕES DAS VARIÁVEIS DE CONTROLE
    #InterfacePppoe -> Recebe o noma da interface PPPoE;
    #TargetPing -> Recebe o IP de destino no qual será ativado o checkgateway;
    #DistanceGateway -> Recebe [int] o distance para a rota default.

    #CriaRotaDefault -> Recebe [true | false] informando se a rota default será criada;
    #EnableScript -> Recebe [true | false] habilitando a execução do script
    #===============================================
    :global InterfacePppoe "pppoe-mobtelecom-200Mb";
    :global TargetPing "208.84.244.116";
    :global DistanceGateway 2;

    :global CriaRotaDefault true;
    :local EnableScript true;

    :global GatePppoe;
    :global GateRoute;

    :global FuncaoRemoveRotaPing do={
        [/ip route remove [find dst-address=($1 . "/32")]];
        :log debug message=("Rotas com destino " . ($1 . "/32") . " excluídas com sucesso.");
    }

    :global FuncaoCriaRotaPing do={
        $FuncaoRemoveRotaPing $1;
        [/ip route add dst-address=($1 . "/32") scope=10 gateway=$2];
        :log debug message=("Rota com destino " . ($1 . "/32") . " e gateway " . $2 . " criada com sucesso.");
    }

    :global FuncaoRemoveRotaDefault do={
        [/ip route remove [find dst-address="0.0.0.0/0" gateway=$1]];
        :log debug message=("Rota default com gateway " . $1 . " excluída com sucesso.");
    }

    :global FuncaoCriaRotaDefault do={
        $FuncaoRemoveRotaDefault $1;
        [/ip route add dst-address="0.0.0.0/0" scope=30 gateway=$1 distance=$2 check-gateway="ping"];
        :log debug message=("Rota default com gateway: " . $1 . " criada com sucesso");
    }
    

    :if ($EnableScript) do={
        :do {
            :set $GatePppoe [/ip address get [find interface=$InterfacePppoe] network];
            :log debug message=("Gateway link PPoE: ".$GatePppoe);
            :do {
                :set $GateRoute [/ip route get [find dst-address=($TargetPing . "/32")] gateway];
                :log debug message=("Gateway IP Route: ".$GateRoute);
                :if ($GatePppoe != $GateRoute) do={
                    :do {
                        $FuncaoCriaRotaPing $TargetPing $GatePppoe;
                        :if ($CriaRotaDefault) do={
                            :log info "Passando-3";
                            $FuncaoCriaRotaDefault $TargetPing $DistanceGateway;
                        } else {
                            :log debug "Criação de rota default desabilitada!";
                        }
                        :log debug "Tabela de roteamento atualizada com sucesso!";
                    } on-error={
                        :log error message=("Ocorreu um erro na exclusão de rotas, informe ao desenvolvedor");
                    }
                } else {
                    :log debug message=("Sem necessidade de atualizar a rota com destino: " . $TargetPing . " e gateway: " . $GateRoute);
                }
            } on-error={
                :log debug message=("A rota com destino " . ($TargetPing . "/32") . " não existe e será criada.");
                :do {
                    $FuncaoCriaRotaPing $TargetPing $GatePppoe;
                    :if ($CriaRotaDefault) do={
                        $FuncaoCriaRotaDefault $TargetPing $DistanceGateway;
                    } else {
                        :log debug "Criação de rota default desabilitada!";
                    }
                } on-error={
                    :log error message=("Ocorreu um erro na criação da rota com destino " . ($TargetPing . "/32") . " e gateway " . $GatePppoe);
                }
            }
        } on-error={
            :log debug message=("A interface PPPoE " . $InterfacePppoe . " não existe! - excluindo rotas caso existam.");
            $FuncaoRemoveRotaDefault $TargetPing;
            $FuncaoRemoveRotaPing $TargetPing;
        }
    } else {
        :log debug message=("A execução do script para monitoramento de gateway do link PPPoE: " . $InterfacePppoe . " está desabilitada.")
    }
    
}