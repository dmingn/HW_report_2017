# ハードウェア構成法 冬休み特訓レポート2017 解答例

v1~v4 の4段階の実装に tag をつけてあります.
(各実装については後述)
Quartus Prime でコンパイルできるようにプロジェクトファイル等を入れてあります.
(Quartus Prime 17.1.0 Lite Edition で確認)

## 問題
> 10ビットの正数 : 変域 1~1023 について,
> 偶数なら2で割る
> 奇数なら3倍して+1する
> を繰り返していると, 数字が大小を繰り返しそのうち1になります.
> これを Collatz 山脈と呼ぶことにします.
> Collats 山脈の最高峰を与える登り口 (=奇数) のうち
> 最も行程の長いスタート地点の数字をルートの名前とします.
> 例えば 7, 8, 9, 10, 11 からスタートした場合
> 最高峰は52になりますが行程の一番長い9をルート名とします.
> 最高峰が高い順に上位4本のルート名とその行程の長さを計算する回路を設計してください.

## ファイル
レポジトリに含まれるファイルについて説明します.

### ソースコード
- collatz.vhd :
    climber, sorter, ram を結び付けて適当に制御します.
    全部終わったかなと思うと (判定が雑かも) alldone フラグを立て,
    clock 数のカウントをストップします.

- climber.vhd :
    go フラグが立つと登り口 (root) から最高峰 (peak) と行程の長さ (len) を計算しながら登山していきます.
    踏破すると done フラグを立てます.

- sorter.vhd :
    山脈の情報 (chain = (root, peak, len)) を受け取り, 適当にソートして上位4本の山脈情報を出力します.

- ram.vhd :
    ram_ip.vhd の wrapper です.
    write_enable が立つと root をアドレスとして write_enable, peak, len を RAM に書き込みます.
    write_enable が立っていないときは root をアドレスとして hit, peak, len を出力します.

- ram_ip.vhd :
    Quartus によって生成された 1-port RAM です.

- ram.mif ;
    RAM の初期化ファイルです.

- testbench.vhd :
    シミュレーション用の testbench です.

- types.vhd :
    複数ファイルにわたって使用する record 型や array 型について書いてあります.

### Quartus 関係
- collatz.qpf :
    project file です.

- collatz.qsf :
    setting file です.
    Device は適当に Cyclone V の 5CGXFC7C7F23C8 を選びました.

- collatz.sdc :
    制約記述ファイルです.
    clock の timing constraint を記述してあります.
    適当に 50MHz にしておきました.

- ram_ip.qip :
    ram_ip.vhd のための環境ファイルです.

- output_files/collatz.flow.rpt :
    コンパイル結果の一部です.
    エレメントの使用状況を見ることができます.

- output_files/collatz.sta.rpt :
    コンパイル結果の一部です.
    最大動作周波数を見ることができます.

## 実装
素朴な実装から始めて少しずつ最適化を施していったので,
その段階ごとに tag をつけました.
各実装について軽く説明します.

### v1 : naive implemantation
特に最適化を施さない素朴な実装のつもりでしたが,
偶数の登り口は飛ばしています.
climber は単純に毎クロック3掛けて1足すか2で割るかしていきます.

### v2 : bousou technique
配布された資料に書かれていた暴走テクニック
(奇数の時は3倍して1足して2で割る, 4の倍数は4で割る)
を実装したものです.

### v3 : priority encoder and barrel shifter
暴走テクニックの発展として,
講義で扱った priority encoder と barrel shifter を用いて偶数を全てスキップしています.

### v4 : ram
既に調査した登り口に対する最高峰の高さと行程の長さを記憶しておくことで再計算を防ぎます.

## 性能
各実装の性能を示します.

### クロック数
シミュレーションによる clk_count の値です.

|           | v1    | v2    | v3    | v4   |
| --------- | ----- | ----- | ----- | ---- |
| clk_count | 34914 | 19905 | 12397 | 3864 |

### 最大動作周波数
output_files/collatz.sta.rpt 内の Slow 1100mV 85 Model Fmax Summary から取ってきた値です.

|                 | v1        | v2        | v3        | v4        |
| --------------- | --------- | --------- | --------- | --------- |
| Fmax            | 51.98 MHz | 52.81 MHz | 53.17 MHz | 54.56 MHz |
| Restricted Fmax | 51.98 MHz | 52.81 MHz | 53.17 MHz | 54.56 MHz |

### エレメント使用状況
output_files/collatz.flow.rpt 内の Flow Summary から取ってきた値です.

|                                 | v1                     | v2                     | v3                     | v4                           |
| ------------------------------- | ---------------------- | ---------------------- | ---------------------- | ---------------------------- |
| Logic utilization (in ALMs)     | 306 / 56,480 ( < 1 % ) | 321 / 56,480 ( < 1 % ) | 378 / 56,480 ( < 1 % ) | 390 / 56,480 ( < 1 % )       |
| Total registers                 | 331                    | 332                    | 325                    | 335                          |
| Total pins                      | 177 / 268 ( 66 % )     | 177 / 268 ( 66 % )     | 177 / 268 ( 66 % )     | 177 / 268 ( 66 % )           |
| Total virtual pins              | 0                      | 0                      | 0                      | 0                            |
| Total block memory bits         | 0 / 7,024,640 ( 0 % )  | 0 / 7,024,640 ( 0 % )  | 0 / 7,024,640 ( 0 % )  | 13,824 / 7,024,640 ( < 1 % ) |
| Total DSP Blocks                | 0 / 156 ( 0 % )        | 0 / 156 ( 0 % )        | 0 / 156 ( 0 % )        | 0 / 156 ( 0 % )              |
| Total HSSI RX PCSs              | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )                |
| Total HSSI PMA RX Deserializers | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )                |
| Total HSSI TX PCSs              | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )                |
| Total HSSI PMA TX Serializers   | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )          | 0 / 6 ( 0 % )                |
| Total PLLs                      | 0 / 13 ( 0 % )         | 0 / 13 ( 0 % )         | 0 / 13 ( 0 % )         | 0 / 13 ( 0 % )               |
| Total DLLs                      | 0 / 4 ( 0 % )          | 0 / 4 ( 0 % )          | 0 / 4 ( 0 % )          | 0 / 4 ( 0 % )                |
