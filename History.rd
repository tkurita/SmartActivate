= To Do

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

