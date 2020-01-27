#!/bin/bash

#SELECT
file=$(dialog --cancel-label "SAIR" --backtitle "- IGOR STINIESKI FAVIN" --ascii-lines --stdout --title "Escolha 2: " --fselect /home/pkill/Desktop/grauA/ 12 48) #Seleciona o arquivo para fazer upload
arquivo=$(sed -n '2,$p' $file &) #Pega o arquivo selecionado e passa para dentro de um array



#Pesquisa pelo CWE ID
function pesquisarCweId()
{
	id=$(dialog --inputbox "Digite uma CWE ID para filtrar: " 8 60 --backtitle "- IGOR STINIESKI FAVIN" --stdout)
	if ! [ $? -eq 1 ];then
		lista=$(awk -F '\t' '$1 ~ /'$id'/{print}' $file | sed 's/\t/\n/g' | sed '1s/^/CVE ID: /'| sed '2s/^/CWE ID: /' | sed '3s/^/Vulnerability Types: /' | sed '4s/^/Publish Date: /' | sed '5s/^/Update Date: /' | sed '6s/^/CVSS Score: /' | sed '7s/^/Gained Access Level: /' | sed '8s/^/Access: /'| sed '9s/^/Complexity: /' | sed '10s/^/Authentication: /' | sed '11s/^/Confidentialy: /' | sed '12s/^/Integrity: /' | sed '13s/^/Availability: /' | sed '14s/^/Description: /')
		dialog --title "Resultado da pesquisa" --msgbox "$lista"  0 0
		menu
	else
		menu
	fi
}



#Pesquisa pela descrição
function pesquisarDescription()
{
	description=$(dialog --inputbox "Digite uma palavra para filtrar:" 8 60 --backtitle "- IGOR STINIESKI FAVIN" --stdout)
	if ! [ $? -eq 1 ];then
		recolher=$(awk "/$description/" $file | sed -n '7,$p' | awk -F '\t' '{print $1"\n"$3"\n"$6"\n"$4"\n"$5"\n"$14}' > description.txt)
		while [ -s description.txt ];do
			if [ -s description.txt ];then
				imprimir=$(head -n6 description.txt | sed '1s/^/CVE ID: /' | sed '2s/^/Vulnerability Types: /' | sed '3s/^/CVSS Score: /' | sed '4s/^/Publish Date: /' | sed '5s/^/Update Date: /' | sed '6s/^/Description: /')
				dialog --title "Resultado da pesquisa:" --msgbox "$imprimir" 0 0
				sed -i '1,6d' description.txt
			fi
		done
		menu
	else
		menu
	fi
}


#Pesquisa pela publishDate
function filtrarPublishDate()
{
	function validarData() #Validar data formato dd/mm/yyyy
	{
		dateIni=0
		dateFin=0
		until [[ "$dateIni" =~ ^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$ && "$dateFin" =~ ^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$ ]]
		do
			dateIni=$(dialog --inputbox "Data Inicial: " 0 0 --backtitle "- IGOR STINIESKI FAVIN" --stdout)
			dateFin=$(dialog --inputbox "Data Final: " 0 0 --backtitle "- IGOR STINIESKI FAVIN" --stdout)
		done
	}
	validarData
	echo $(date %Y/%m/%d $dateIni)
	dateInicial=$(date "+%Y-%m-%d" -d $dateIni)
	dateFinal=$(date "+%Y-%m-%d" -d $dateFin)
	lista=$(awk -F '\t' '$4 ~ /'$dateInicial'/'$dateFinal'/{print}' $file)
	dialog --title "Resultado da pesquisa:" --msgbox "$lista" 0 0
}



#Contagem de CWE ID
function contagemCweId()
{
	function validarInteiro()
	{
	contMin=""
	contMax=""
	while ! [[ "$contMin" =~ ^[0-9]+$ && "$contMax" =~ ^[0-9]+$ || $? -eq 1 ]];do #Ou volta ou preenche com inteiro
		contMin=$(dialog --no-cancel --inputbox "Quantidade Minima: " 0 0 --backtitle "- IGOR STINIESKI FAVIN" --stdout)
		contMax=$(dialog --cancel-label "Voltar" --inputbox "Quantidade Maxima: " 0 0 --backtitle "- IGOR STINIESKI FAVIN" --stdout)
	done
	export voltar=$? #variavel gloval para verificar a resposta
	}
	validarInteiro
	function verificarContagem()
	{
		dialog --title "-----Pesquisando-----" --infobox "Aguarde um momento..." 0 0;sleep 1
		if [ $voltar -eq 1 ];then #Confirma se o usuario selecionou voltar e manda para o menu novamente
			menu
		elif [ $contMin -le $contMax ];then #Faz a contagem	
			lista=$(awk -F '\t' '{print $2}' $file | sed -n '2,$p')
			contados=()
			total=()
			for i in $lista;do
				igual=false
				for j in ${contados[@]}; do
					if [ $i -eq $j ];then
						igual=true
					fi
				done
				if ! $igual; then
					total+=($(awk -F '\t' '{print $2}' $file | grep -wc $i))
					contados+=($i)
				else
					continue
				fi
			done
			j=0
			for i in ${total[@]};do
				if [[ $i -le $contMax && $i -ge $contMin ]];then
					resultado+="${total[$j]}:${contados[$j]} " 
				fi
				let j++
			done

			echo "Quantidade:Numero" > resultadoProcura.txt
			for i in ${resultado[@]};do
				echo $i >> resultadoProcura.txt
			done
			dialog --title "" --textbox resultadoProcura.txt 0 0
			menu
		else
			dialog --ascii-lines --title "!!!!!Informação Inválida!!!!!" --msgbox "\nPor favor insira um numero inteiro minimo, inferior ao maximo!" 7 65
			validarInteiro
			verificarContagem
		fi
	}
	verificarContagem
}


#MENU
function menu()
{
	resp=$(dialog --stdout --title "MENU" --cancel-label "SAIR" --backtitle "- IGOR STINIESKI FAVIN" --ascii-lines --menu "Escolha uma opção abaixo >>>" 0 0 0 "1. CVE ID" "Pesquisa pelo CVE ID" "2. DESCRIPTION" "Pesquisa a palavra no conteudo da vulnerabilidade" "3. PUBLISH DATE" "Pesquisa pela data de publicação" "4. CWE ID COUNT" "Mostra quantas vezes aparece certa CWE ID organizando da maior contagem para menor do score" "5. DIVISION BY SCORE" "Realiza a divisão de grupos pelo score" "6. EXPORT DATA" "Filtra o arquivo e salva ele em um arquivo texto" --stdout)
	echo $resp
	case "$resp" in
		"1. CVE ID")
			pesquisarCweId
			;;
		"2. DESCRIPTION")
			pesquisarDescription
			;;
		"3. PUBLISH DATE")
			filtrarPublishDate
			;;
		"4. CWE ID COUNT")
			contagemCweId
			;;
		*)
				
	esac
}
menu
