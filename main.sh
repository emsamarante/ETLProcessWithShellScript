#!/usr/bin/env bash

# -------------------------------------------------------------------------------------------
# Author: Eduardo Amarante
# LinkedIn: https://www.linkedin.com/in/eduardo-amarante/
# Portfolio: emsamarante.github.io
#---------------------------------------------------------------------------------------------
# Version: 1.0 # Date: 2023/06/14
# Version: 1.1 # Date: 2023/06/20 - Changing in command to install lynx
#---------------------------------------------------------------------------------------------
# Bash Version: 5.0.17(1)
#---------------------------------------------------------------------------------------------
# Description: Content site extraction of only two types of books and save the structured data in text file.
# For the next version I'll include the extraction of pictures.
#
# --------------------------------------------------------------------------------------------
# Content:
# main: file of extraction
# save: file of savings
#---------------------------------------------------------------------------------------------
# Variables:

URL="http://books.toscrape.com"
TOTAL=2
i=
PAGES="/catalogue/page-"$i".html"
PAGE="/catalogue/category/books/travel_2/index.html"
CATALOGUE="/catalogue/category/books"
SITE=$URL$PAGE
LINKS=()
ARQ="content.txt"
ARQUIVO="conteudo.txt"

echo > "$ARQUIVO"

#----------------------------------------------------------------------------------------------
# Test
#
[ ! -x "$(which lynx)" ] && echo "Instaling dependencies..." && sudo apt install lynx && echo
[ ! -x "$(which lynx)" ] && echo "Dependency doesn't exist." && exit 1
[ -e "tipolivro.txt" ] && rm -rf "tipolivro.txt"
[ ! -e "output" ] && mkdir "output"
[ -e "output/registro.txt" ] && rm -rf "registro.txt"
[ -e "pages.txt" ] && rm -rf "pages.txt"
[ -e "output/livros.txt" ] && rm -rf "livros.txt"
[ ! -x "save.sh" ] && echo "Giving permission..." && chmod +x save.sh && echo

#----------------------------------------------------------------------------------------------
echo "Tests ended sucessfully!" && echo

# Execution
#
lynx -source $SITE > "$ARQ"

TIPOS_LINKS=$(cat content.txt| grep "catalogue/category/books" | sed s'/<a.*="//;s/">//')
LISTA=($TIPOS_LINKS)

echo >"titulos.txt"
echo >"precos.txt"
echo >"classificacao.txt"

#----------------------------------------------------------------------------------------------
# Functions
#
GravaTitulos () {
    local TITULOS=$(cat $ARQUIVO | grep "<h3>" |  sed 's/<h3.*title=//;s/>.*//')
    echo "$TITULOS" > "titulos.txt"

    LTITULOS=()
    IFS='$"'
    j=1
    for i in $TITULOS;
    do
        [ `expr $j % 2` == 0 ] && LTITULOS+=($i) #&& echo "$i - $j" 
        j=$(($j+1))
    done   
    LTITULOS="${LTITULOS[@]}"
}

GravaPrecos () {
     PRECOS=$(cat $ARQUIVO | grep "price_color" |  sed 's/<p.*">//;s/<\/p>//')
     PRECO=\"$PRECOS\"
    echo "$PRECO" > "precos.txt" 
}

GravaClassificacao () {
    local CLASSIFICACAO=$(cat $ARQUIVO | grep "<p class=.star-rating." | sed 's/.*ing//;s/.>//')
    local CLASS=\"$CLASSIFICACAO\"
    echo "$CLASS" > "classificacao.txt"
}

GravaTipo () {
    local TIPOLIVRO=\"$TIPO\"
    echo "$TIPOLIVRO" >> "tipolivro.txt"
}
#---------------------------------------------------------------------------------------------------
# Extraction of types of books
LISTA=$(cat "content.txt" | grep "<a href=\"\.\.\/[a-z]" | sed 's/<a href="\.\.//;s/">//')
LLISTA=($LISTA)

echo "${LLISTA[@]}" > "pages.txt"

# Extraction part ----------------------------------------------------------------------------------
count=1
while read -r -d\n linha
do
    if [[ count -le $TOTAL ]]; then
        # echo "$URL$CATALOGUE${LLISTA[count]}"
        SITE="$URL$CATALOGUE${LLISTA[count]}"
        
        # falta verificar isso aqui
        TIPO=`(echo ${LLISTA[count]} | sed 's/_.*//;s/\///')`

        #echo "$TIPO"

        lynx -source $SITE >> "$ARQUIVO"
        sleep 2

        GravaTitulos "SARQUIVO"
        GravaPrecos "$ARQUIVO"
        GravaClassificacao "$ARQUIVO"
        GravaTipo "$ARQUIVO"
            
        count=$(($count+1))
    fi
done <"$ARQ"


echo "Extractions completed successly!" && echo

echo "Total de pages: $TOTAL" > "output/registro.txt"

# Saving ----------------------
./save.sh

