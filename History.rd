= To Do
activate コマンドで失敗した時、失敗理由を出力した方がいいだろう。
終了ステータスもエラーの種類によって使い分ける。

= 2010-11-06
activate コマンドを 64 bit でコンパイルすると次のような warning がでる。でも、動くみたい。
warning: passing argument 2 of ‘libiconv’ from incompatible pointer type

= 2007-03-26
SHIFT_JIS ではなく、SJIS でも動くみたい

while loop のなかで、char *outbuf を確保しなおすと、うまくいくようだ。

iconv を連続して call すると、outbuf の続きに書き込むようだ。
outbuf の先頭に書き込んでくれない。
iconv を呼んだ後だと、reallocになぜか失敗する。
iconv_open - iconv_close を実行するようにしよう。

= 2007-03-23
querylocale(3)           - Get locale name for a specified category
LC_CTYPE を使うのがいいかも？

[NSLocale currentLocale] は環境変数 LANG を反映しない。
NSScriptCode とは何？ encoding とは違うようだ

= 2007.03.20
version 1.0.3
* Cocoa をリンクしないようにした。
* .sdef -> .r をビルドプロセスに含めた
sdef をビルドフェースに含めると warnning がでる。
Checking DependenciesWarning: Multiple build commands for output file /Users/tkurita/Dev/Projects/SmartActivate/trunk/build/SmartActivate.build/Release/SmartActivateApp.build/ResourceManagerResources/Objects/SmartActivate-A0862672.rsrc
universal binary を off にするとおきない。
*.sdef を取り除くと起きない。
* ResourceManager ビルドから SmartActivate.r を取り除くいても起きる。

しょうがない、カスタムルールはあきらめて シェルスクリプトで .sdef->.rを処理する。これはうまくいくみたい

= 2007.03.06
OSAX を Objective C を使わないようにする。
他のプロセスの class SmartActivate が有効にならない。

= 2007.02.27
OSAX の Cocoa への依存をなくした。

= 2007.02.26
10.4.8
SAIsBusy で return true しなくても、アプリケーションはクラッシュしなくなったようだ。

