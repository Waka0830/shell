#!/bin/bash
topic_name=$1
msg_type=$2

seq_param=""
ran_param=""
layer_num=1
flag=0

#引数の個数が違う場合, Usageを表示
function print_usage_and_exit() {
  echo "Usage: rospub_tool.sh <topic_name> <msg_type> <filename>"
  exit 1
}

if [ $# -ne 3 ]; then
  print_usage_and_exit
fi


#パラメータ(txtファイル)の読み込み
while read line || [ -n "${line}" ] #最終行で改行が無くても, read lineを実行するために || を入れている
do
    param_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 1` #パラメータの種類を保持(x, y等)
    inst_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 2` #seq等の指示か数値かという判別を行う情報を保持
    if [ "$inst_checker" = "seq" ]; then
        seq_param=${param_checker}
        start=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 3`
        step=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 4`
        stop=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 5`
    fi
    if [ "$inst_checker" = "ran" ]; then
        ran_param=${param_checker}
        min=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 3`
        max=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 4`
        loop=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 5`
    fi
done < ./$3 #ファイル名


#while : #ループしたい場合ここのコメントアウトを外す
#do
    if [ "$seq_param" != "" ] && [ "$ran_param" != "" ]; then
        echo "Error: choose only one of \"seq\" or \"ran\"" 
    elif [ "$seq_param" = "" ] && [ "$ran_param" = "" ]; then #seq等の指示がなかった場合, 1回のみ出力
        str="{"
        separator=""
        while read line || [ -n "${line}" ]
        do
            if [ "${line}" != "" ]; then #空行は無視する
                param_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 1`
                inst_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 2`
                if [ "${line}" = ";" ]; then #行が「;」と一致する時かっこを閉じる
                    str="${str}}"
                    layer_num=$((layer_num - 1))
                    continue #whileループを進める
                fi
                str="${str}${separator}${line}"
                if [ "${separator}" = "" ]; then #最初の数字・パラメータ文字の直後はカンマを入れない
                    separator=", "
                fi
                if [ "${inst_checker}" = "${param_checker}" ]; then
                    layer_num=$((layer_num + 1))
                    str="${str}: {"
                    separator=""
                fi
            fi
        done < ./$3 #ファイル名
        while : #層の数だけかっこを閉じる
        do
            if [ "${layer_num}" = "0" ]; then
                break
            fi
            str="${str}}"
            layer_num=$((layer_num - 1))
        done
        echo "ros2 topic pub --once ${topic_name} ${msg_type} "\"${str}"\"" #動作確認用
        #eval "ros2 topic pub --once ${topic_name} ${msg_type} "\"${str}"\"" #実際にpublishする場合はこの行を実行

    elif [ "$ran_param" = "" ]; then
        #seqがあった場合, 指定された回数だけ出力
        for i in `seq ${start} ${step} ${stop}`
        do
            layer_num=1
            str="{"
            separator=""

            while read line || [ -n "${line}" ]
            do
                if [ "${line}" != "" ]; then #空行は無視する
                    param_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 1`
                    inst_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 2`
                    if [ "${line}" = ";" ]; then #行が「;」と一致する時かっこを閉じる
                        str="${str}}"
                        layer_num=$((layer_num - 1))
                        continue #whileループを進める
                    fi
                    if [ "$param_checker" = "${seq_param}" ] && [ "${flag}" = "0" ]; then #seqを含む行の処理
                        str="${str}${separator}${param_checker} ${i}"
                        flag=1 #このファイルにおいてすでにseqを含むパラメータが登場したことを示す (flagの管理を行わないと複数個の「x:」等が登場した時挙動がおかしくなる)
                    else #seqを含まない行の処理
                        str="${str}${separator}${line}"
                    fi
                    if [ "${separator}" = "" ]; then #最初の数字・パラメータ文字の直後はカンマを入れない
                        separator=", "
                    fi
                    if [ "${inst_checker}" = "${param_checker}" ]; then
                        layer_num=$((layer_num + 1))
                        str="${str}: {"
                        separator=""
                    fi
                fi
            done < ./$3 #ファイル名
            flag=0
            while : #層の数だけかっこを閉じる
            do
                if [ "${layer_num}" = "0" ]; then
                    break
                fi
                str="${str}}"
                layer_num=$((layer_num - 1))
            done
            echo "ros2 topic pub --once ${topic_name} ${msg_type} "\"${str}"\"" #動作確認用
            #eval "ros2 topic pub --once ${topic_name} ${msg_type} "\"${str}"\"" #実際にpublishする場合はこの行を実行
            sleep 1
        done
        echo "Publish finished."
    elif [ "$seq_param" = "" ]; then
        #ranがあった場合, 指定された回数だけ出力
        for i in `seq 1 1 ${loop}`
        do
            layer_num=1
            random_num=$(($RANDOM % ($max - $min) + $min))
            str="{"
            separator=""

            while read line || [ -n "${line}" ]
            do
                if [ "${line}" != "" ]; then #空行は無視する
                    param_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 1`
                    inst_checker=`echo ${line} | tr -s ' ' ' ' | cut -d" " -f 2`
                    if [ "${line}" = ";" ]; then #行が「;」と一致する時かっこを閉じる
                        str="${str}}"
                        layer_num=$((layer_num - 1))
                        continue #whileループを進める
                    fi
                    if [ "$param_checker" = "${ran_param}" ] && [ "${flag}" = "0" ]; then #ranを含む行の処理
                        str="${str}${separator}${param_checker} ${random_num}"
                        flag=1 #このファイルにおいてすでにranを含むパラメータが登場したことを示す (flagの管理を行わないと複数個の「x:」等が登場した時挙動がおかしくなる)
                    else #ranを含まない行の処理
                        str="${str}${separator}${line}"
                    fi
                    if [ "${separator}" = "" ]; then #最初の数字・パラメータ文字の直後はカンマを入れない
                        separator=", "
                    fi
                    if [ "${inst_checker}" = "${param_checker}" ]; then
                        layer_num=$((layer_num + 1))
                        str="${str}: {"
                        separator=""
                    fi
                fi
            done < ./$3 #ファイル名
            flag=0
            while : #層の数だけかっこを閉じる
            do
                if [ "${layer_num}" = "0" ]; then
                    break
                fi
                str="${str}}"
                layer_num=$((layer_num - 1))
            done
            echo "ros2 topic pub --once ${topic_name} ${msg_type} "\"${str}"\"" #動作確認用
            #eval "ros2 topic pub --once ${topic_name} ${msg_type} "\"${str}"\"" #実際にpublishする場合はこの行を実行
            sleep 1
        done
        echo "Publish finished."
    fi
#done