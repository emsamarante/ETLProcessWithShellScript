#!/usr/bin/env bash

# This script saves the records in text file.
# Version: 1.0

# Tests --------------------------------------------------------------------------------
[ ! -e "titulos.txt" ] && echo "Error. File doesn't exist. 1" && exit 1 
[ ! -e "precos.txt" ] && echo "Error. File doesn't exist. 2" && exit 1 
[ ! -e "classificacao.txt" ] && echo "Error. File doesn't exist. 3" && exit 1 
[ ! -e "output/registro.txt" ] && echo "Error. File doesn't exist. 4" && exit 1

# Variables -----------------------------------------------------------------------------
PRECOS=$(cat "precos.txt" | sed 's/        //')
CLASSIFICACAO=$(cat "classificacao.txt" | sed 's/        //' | sed 's/ //')
TITULOS=$(cat "titulos.txt")
TOTAL=$(cat "output/registro.txt" | head -n 1 |sed 's/.*: //')
TIPO=$(cat "tipolivro.txt" | sed 's/-/ /')

arrPrecos=($PRECOS)
arrClassificacao=($CLASSIFICACAO)

arrTitulos=()
IFS='$"'
j=1
for i in $TITULOS;
do
    [ `expr $j % 2` == 0 ] && arrTitulos+=($i) #&& echo "$i - $j" 
    j=$(($j+1))
done   

echo "Total of books: ${#arrPrecos[@]}" >> "output/registro.txt"

arrTotal=($TOTAL)

arrTipo=()
IFS='$"'
j=1
for i in $TIPO;
do
    [ `expr $j % 2` == 0 ] && arrTipo+=($i) #&& echo "$i - $j" 
    j=$(($j+1))
done   


# Write records -------------------------------------------------------------------------
echo "ID|title|ratings|Prices|Type"> "output/livros.txt"

GravaRegistro() {
    count=0
    numTipo=0
    for i in ${arrTitulos[@]};
    do
        if [[ $count -lt ${#arrTitulos[@]}/$TOTAL ]]; 
        then
            numTipo=0
        else
            numTipo=1
        fi
                
        echo "$count|${arrTitulos[count]}|${arrClassificacao[count]}|${arrPrecos[count]} |${arrTipo[numTipo]} " >> "output/livros.txt"
        count=$(($count+1))
    done
}

GravaRegistro

echo "Thanks! The results was recorded in output/livros.txt"
rm -rf "conteudo.txt" "precos.txt" "classificacao.txt" "titulos.txt" "pages.txt" "content.txt" "tipolivro.txt"
