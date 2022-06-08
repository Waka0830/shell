rospub_tool.shの使い方

実行形式
    sh rospub_tool.sh <topic_name> <msg_type> <filename>

実行例
    sh rospub_tool.sh /turtle1/cmd_vel geometry_msgs/msg/Twist param.txt

以下に実行例を示す. *が付いたものは, 実際の形式が異なるためこのままturtle_simにpublishは出来ない.

・param.txtの例1*: 1階層のパラメータ
    x: 2.0
    y: 2.0
    z: 2.0
・実行結果例1
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{x: 2.0, y: 2.0, z: 2.0}"

・param.txtの例2: 2階層のパラメータ
    linear
    x: 2.0
    y: 2.0
    z: 2.0
    ;
    angular
    x: 0.0
    y: 0.0
    z: 1.8
・実行結果例2
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 2.0, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
・補足
    「;」という行を入れることで, 階層を1段階上げることが出来る.

・param.txtの例3*: 2階層のパラメータ
    linear
    x: 2.0
    y: 2.0
    angular
    x: 0.0
    y: 0.0
    z: 1.8
・実行結果例3
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 2.0, z: 2.0, angular: {x: 0.0, y: 0.0, z: 1.8}}}"
・補足
    「;」の行を省略すると, そのまま階層が下がっていく. (実行結果例2, 3を参考)

・param.txtの例4: 昇順・降順にパラメータを変更させながら連続publish
    linear
    x: 2.0
    y: seq 3 2 10
    z: 2.0
    ;
    angular
    x: 0.0
    y: 0.0
    z: 1.8
・実行結果例4
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 3, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 5, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 7, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 9, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
    Publish finished.
・補足
    どれか1つのパラメータについて, seq <start> <step> <stop> の形式で変数範囲を指定出来る.


・param.txtの例5: ランダムにパラメータを変更させながら連続publish
    linear
    x: 2.0
    y: ran 37 104 3
    z: 2.0
    ;
    angular
    x: 0.0
    y: 0.0
    z: 1.8
・実行結果例5
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 66, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 99, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
    ros2 topic pub --once /turtle1/cmd_vel geometry_msgs/msg/Twist "{linear: {x: 2.0, y: 94, z: 2.0}, angular: {x: 0.0, y: 0.0, z: 1.8}}"
    Publish finished.
・補足
    どれか1つのパラメータについて, ran <min> <max> <loop> の形式で乱数範囲・ループ(実行)回数を指定出来る.