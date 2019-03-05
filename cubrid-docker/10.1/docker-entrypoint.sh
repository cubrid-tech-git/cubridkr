#!/bin/bash
set -eo pipefail
shopt -s nullglob

# 데이터베이스 기본 문자셋을 설정합니다.
# '$CUBRID_CHARSET' 환경변수를 설정하지 않으면 'ko_KR.utf8'을 기본 문자셋으로 설정합니다.
if [[ -z "$CUBRID_CHARSET" ]]; then
    CUBRID_CHARSET='ko_KR.utf8'
fi

# 컨테이너 시작 시 생성할 데이터베이스 이름을 설정합니다.
# '$CUBRID_DATABASE' 환경변수를 설정하지 않으면 'demodb'를 기본 데이터베이스로 설정합니다.
if [[ -z "$CUBRID_DATABASE" ]]; then
    CUBRID_DATABASE='demodb'
fi

# 데이터베이스에서 사용할 사용자 계정의 이름을 설정합니다.
# '$CUBRID_USER' 환경변수를 설정하지 않은면 'dba'를 기본 사용자로 설정합니다.
if [[ -z "$CUBRID_USER" ]]; then
    CUBRID_USER='dba'
fi

# 데이터베이스에서 사용할 'dba' 계정의 비밀번호와 사용자 계정의 비밀번호를 설정합니다.
# '$CUBRID_DBA_PASSWORD', '$CUBRID_PASSWORD' 환경변수를 확인하여 각각 설정합니다.
# 두 환경변수 중에 하나만 설정되어 있으면 두 환경변수 모두 동일한 값으로 설정합니다.
# 두 환경변수 모두 설정되어 있지 않으면 '$CUBRID_PASSWORD_EMPTY' 환경변수 값을 1로 설정합니다.
if [[ ! -z "$CUBRID_DBA_PASSWORD" || -z "$CUBRID_PASSWORD" ]]; then
    CUBRID_PASSWORD="$CUBRID_DBA_PASSWORD"
elif [[ -z "$CUBRID_DBA_PASSWORD" || ! -z "$CUBRID_PASSWORD" ]]; then
    CUBRID_DBA_PASSWORD="$CUBRID_PASSWORD"
elif [[ -z "$CUBRID_DBA_PASSWORD" || -z "$CUBRID_PASSWORD" ]]; then
    CUBRID_PASSWORD_EMPTY=1
fi

if [[ ! -e /home/cubrid/cubrid.lck ]]; then
    # 컨테이너 시작 시 '$CUBRID_DATABASE' 환경변수에 설정된 이름으로 데이터베이스를 생성합니다.
    su - cubrid -c "mkdir -p \$CUBRID_DATABASES/$CUBRID_DATABASE && cubrid createdb -F \$CUBRID_DATABASES/$CUBRID_DATABASE $CUBRID_DATABASE $CUBRID_CHARSET"
    su - cubrid -c "sed s/#server=foo,bar/server=$CUBRID_DATABASE/g -i \$CUBRID/conf/cubrid.conf"

    # 기본 사용자 계정이 'dba'기 아니면 '$CUBRID_USER' 환경변수 값으로 사용자 계정을 생성합니다.
    if [[ ! "$CUBRID_USER" = 'dba' ]]; then
        su - cubrid -c "csql -u dba $CUBRID_DATABASE -S -c \"create user $CUBRID_USER\""
    fi

    # 기본 데이터베이스가 'demodb'이면 '$CUBRID_USER' 환경변수로 설정한 계정에 DEMO 데이터를 생성합니다.
    if [[ "$CUBRID_DATABASE" = 'demodb' ]]; then
        su - cubrid -c "cubrid loaddb -u $CUBRID_USER -s \$CUBRID/demo/demodb_schema -d \$CUBRID/demo/demodb_objects -v $CUBRID_DATABASE"
    fi

    # '$CUBRID_PASSWORD_EMPTY' 환경변수 값이 1이 아니면 '$CUBRID_DBA_PASSWORD' 환경변수 값으로 DBA 계정의 비밀번호를 설정합니다.
    if [[ ! "$CUBRID_PASSWORD_EMPTY" = 1 ]]; then
        su - cubrid -c "csql -u dba $CUBRID_DATABASE -S -c \"alter user dba password '$CUBRID_DBA_PASSWORD'\""
    fi

    # '$CUBRID_PASSWORD_EMPTY' 환경변수 값이 1이 아니면 '$CUBRID_PASSWORD' 환경변수 값으로 사용자 계정의 비밀번호를 설정합니다.
    if [[ ! "$CUBRID_PASSWORD_EMPTY" = 1 ]]; then
        su - cubrid -c "csql -u dba -p '$CUBRID_DBA_PASSWORD' $CUBRID_DATABASE -S -c \"alter user $CUBRID_USER password '$CUBRID_PASSWORD'\""
    fi

    su - cubrid -c "touch \$HOME/cubrid.lck"
fi

# '/docker-entrypoint-initdb.d' 디렉터리에 있는 '*.sql' 파일들을 csql 유틸리티로 실행합니다.
echo
for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
        *.sql)    echo "$0: running $f"; su - cubrid -c "csql -u $CUBRID_USER -p $CUBRID_PASSWORD $CUBRID_DATABASE -S -i \"$f\""; echo ;;
        *)        echo "$0: ignoring $f" ;;
    esac
    echo
done

# 'dba' 계정의 비밀번호와 사용자 계정의 비밀번호가 설정되어 있는 '$CUBRID_DBA_PASSWORD', '$CUBRID_PASSWORD' 두 환경변수를 제거합니다.
unset CUBRID_DBA_PASSWORD
unset CUBRID_PASSWORD

echo
echo 'CUBRID init process complete. Ready for start up.'
echo

# Container가 비정상 종료되었을 경우 CUBRID 서비스를 정상적으로 종료 후에 CSQL 유틸리티로 Standalnoe 모드 접속 테스트를 합니다.
su - cubrid -c "cubrid service stop"
csql -u dba -t -N $CUBRID_DATABASE -S -c 'SELECT VERSION()'

# CSQL 유틸리티로 Standalnoe 모드 접속 테스트에 문제가 없으면 CUBRID 서비스를 시작합니다.
if [[ $? == 0 ]]; then
        su - cubrid -c "cubrid service start"

        tail -f /dev/null
fi


tail -f /dev/null
