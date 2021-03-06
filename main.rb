#! ruby -E utf-8

require 'dxruby'
require './system/tsukasa.rb'

width = 800
height = 600

#ベース背景色
Window.bgcolor=[0,0,0]
#初期化
Window.resize(width, height)

tsukasa = Tsukasa.new({ :width => width,
                        :height => height,
                        })
#ゲームループ
Window.loop(true) do
  #pp "frame"
  #Ragエンジン処理
  tsukasa.update
  #Ragエンジン描画
  tsukasa.render(0, 0, Window)
  
  #スクリプトで終了コマンドが実行された場合
  break if tsukasa.close?
end
