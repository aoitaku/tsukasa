#! ruby -E utf-8

require 'dxruby'

###############################################################################
#TSUKASA for DXRuby  α１
#汎用ゲームエンジン「司（TSUKASA）」 for DXRuby
#
#Copyright (c) <2013-2015> <tsukasa TSUCHIYA>
#
#This software is provided 'as-is', without any express or implied
#warranty. In no event will the authors be held liable for any damages
#arising from the use of this software.
#
#Permission is granted to anyone to use this software for any purpose,
#including commercial applications, and to alter it and redistribute it
#freely, subject to the following restrictions:
#
#   1. The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated but is not required.
#
#   2. Altered source versions must be plainly marked as such, and must not be
#   misrepresented as being the original software.
#
#   3. This notice may not be removed or altered from any source
#   distribution.
#
#[The zlib/libpng License http://opensource.org/licenses/Zlib]
###############################################################################

###############################################################################
#システムサポート
###############################################################################


_CREATE_ :LayoutControl do
  _LOOP_ do
    #ウィンドウの閉じるボタンが押された場合に呼びだされる。
    _CHECK_ mouse: [:on_requested_close] do
      _SEND_ROOT_ do
        _EXIT_ #アプリを終了する
      end
    end
    _END_FRAME_
  end
end

#指定フレーム数ウェイト
#ex. wait_count 60
_DEFINE_ :wait_count do |options|
  _WAIT_ count: options[:_ARGUMENT_]
end

#指定コマンドウェイト
#ex. wait_command :_MOVE_ 
_DEFINE_ :wait_command do |options|
  _WAIT_ command: options[:_ARGUMENT_]
end

###############################################################################
#テキストレイヤ関連
###############################################################################

#標準ポーズコマンド
_DEFINE_ :pause do |options|
  _SEND_ default: :TextLayer do 
    put_icon options[:icon]
    pause options
  end

  #■ルートの待機処理
  #スリープ状態に移行
  _SET_ :_TEMP_, sleep: true

  #ウェイク状態まで待機
  _WAIT_ :_TEMP_,  key_down: K_RCONTROL, 
          equal: {sleep: false} do
    _YIELD_
  end

  #クリック待ちアイコンを削除
  _SEND_ default: :TextLayer do 
    _SEND_ :icon do
      _DELETE_
    end
  end

  #１フレ分は必ず表示させる
  _END_FRAME_ 
end

#行クリック待ちポーズ
_DEFINE_ :line_pause do
  pause icon: :line_icon_func
end

#行クリック待ちポーズ(line_pauseの省略板)
_DEFINE_ :lp do
  line_pause
end

#ページクリック待ちポーズ
_DEFINE_ :page_pause do
  pause icon: :page_icon_func
  _SEND_ default: :TextLayer  do
    _FLUSH_
  end
end

###############################################################################
#デフォルトのレイヤ群
###############################################################################

#標準テキストウィンドウ
_DEFINE_ :TextWindow do |options|
  _CREATE_ :RenderTargetControl,
    x: options[:x],
    y: options[:y],
    width: options[:width],
    height: options[:height],
    id: options[:id] do
      #デフォルトの背景画像
      _CREATE_ :ImageControl, id: :bg
      ##このコントロールにload_imageを実行すると背景画像をセットできる。
      ##ex.
      ##  _SEND_ :message0 do
      ##    _SEND_ :bg do
      ##      _SET_ file_path: "./sozai/bg_test.jpg" 
      ##    end
      ##  end

      #メッセージウィンドウ
      _CREATE_ :TextPageControl, 
        x: 0,
        y: 0,
        width: options[:width],
        size: 32, 
        font_name: "ＭＳＰ ゴシック",
        wait_frame: 2 do
          _CHAR_RENDERER_ do
            #フェードイン（スペースキーか右CTRLが押されたらスキップ）
            _MOVE_   15, alpha:[0,255],
                  option: {check: {key_down: K_RCONTROL, key_push: K_SPACE}} do
                    _SET_ alpha: 255
                  end
            #トランジションが終了するまで待機
            _WAIT_  command: :_MOVE_ 
            #待機フラグを立てる
            _SET_ :_TEMP_, sleep: true
            #待機フラグが下がるまで待機
            _WAIT_ :_TEMP_, equal: {sleep: false}
            #キー入力伝搬を防ぐ為に１フレ送る
            _END_FRAME_
            #ハーフフェードアウト（スペースキーか右CTRLが押されたらスキップ）
            _MOVE_  60,  alpha:128,
                  option: {
                  check: {:key_down => K_RCONTROL, :key_push => K_SPACE}} do
                    #スキップされた場合
                    _CHECK_ key_down: K_RCONTROL do
                      #CTRLスキップ中であれば透明度255
                      _SET_ alpha: 255
                    end
                    _CHECK_ key_push: K_SPACE do
                      #CTRLスキップ中でなければ透明度128
                      _SET_ alpha: 128
                    end
            end
            #トランジションが終了するまで待機
            _WAIT_ command: :_MOVE_ 
          end
          _SET_ size: 32
      end
    #文字列出力
    _DEFINE_ :_TEXT_ do |options|
      _SEND_ 1 do
        _TEXT_ options
      end
    end
    #改行
    _DEFINE_ :_LINE_FEED_ do
      _SEND_ 1  do
        _LINE_FEED_
      end
    end
    #_rubi_デフォルト送信
    _DEFINE_ :_RUBI_ do |options|
      _SEND_ 1 do
        _RUBI_ options[:_ARGUMENT_], text: options[:text]
      end
    end
    #_flush_デフォルト送信
    _DEFINE_ :_FLUSH_ do
      _SEND_ 1  do
        _FLUSH_
      end
    end
    #_flush_デフォルト送信
    _DEFINE_ :_SET_FONT_ do |options|
      _SEND_ 1  do
        _SET_ options
      end
    end

    #キー入力待ち処理
    _DEFINE_ :pause do |options|
      _SEND_ 1 do
        _END_FRAME_

        #スペースキーあるいはCTRLキーの押下待機
        _WAIT_  key_down: K_RCONTROL,
                key_push: K_SPACE

        #ウェイクに移行
        _SET_ :_TEMP_, sleep: false
      end
    end

    #クリック待ちアイコン表示処理
    _DEFINE_ :put_icon do |options|
      #絶対座標表示
      if options[:absolute]
        _CALL_ options[:_ARGUMENT_], x:100, y:100, align_y: :none, float_mode: :none
      #相対座標表示
      else
        _SEND_ 1 do
          _SEND_ :last do
            _CALL_ options[:_ARGUMENT_], align_y: :bottom, float_mode: :left
          end
        end
      end
    end
    _YIELD_
  end
end

TextWindow id: :text0, text_page_id: :default_text_page_control0,
  x: 128,
  y: 256 + 192,
  width: 1024,
  height: 192,
  z: 1000000 #描画順序


=begin
#全画面の場合
TextWindow id: :text1, text_page_id: :default_text_page_control0,
  x: 64,
  y: 64,
  width: 1024,
  height: 768,
  z: 1000000 #描画順序
=end

_DEFINE_ :line_icon_func do |options|
  _CREATE_ :RenderTargetControl, 
          :x => options[:x] || 0, 
          :y => options[:y] || 0, 
          :width => 24,
          :height => 24,
          :align_y => options[:align_y] || :bottom,
          :float_mode => options[:float_mode] || :left,
          :id => :icon do
    _CREATE_ :TileImageControl, 
            :tiles => true,
            :file_path=>"./sozai/icon/icon_8_a.png", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 2 do
      _INCLUDE_ "./sozai/icon/icon_8_a.rb"
    end
    _YIELD_
  end
end

_DEFINE_ :page_icon_func do |options|
  _CREATE_ :RenderTargetControl, 
          :x => options[:x] || 0, 
          :y => options[:y] || 0, 
          :width => 24,
          :height => 24,
          :align_y => options[:align_y] || :bottom,
          :float_mode => options[:float_mode] || :left,
          :id => :icon do
    _CREATE_ :TileImageControl, 
            :tiles => true, 
            :file_path=>"./sozai/icon/icon_4_a.png", 
            :id=>:test, 
            :x_count => 4, 
            :y_count => 1 do
      _LOOP_ do
        _SEND_(3){_SET_  visible: false}
        _SEND_(0){_SET_  visible: true}
      	_WAIT_  count: 5
        _SEND_(0){_SET_  visible: false}
        _SEND_(1){_SET_  visible: true}
      	_WAIT_  count: 5
        _SEND_(1){_SET_  visible: false}
        _SEND_(2){_SET_  visible: true}
      	_WAIT_  count: 5
        _SEND_(2){_SET_  visible: false}
        _SEND_(3){_SET_  visible: true}
      	_WAIT_  count: 5
      end
    end
    _YIELD_
  end
end

#初期レイヤ（背景）
_CREATE_ :ImageControl,
  z: 0, #描画順序
  id: :base do
end

#初期レイヤ０
_CREATE_ :ImageControl,
  z: 100, #描画順序
  id: :img0 do
end

#初期レイヤ１
_CREATE_ :ImageControl,
  z: 2000, #描画順序
  id: :img1 do
end

#初期レイヤ２
_CREATE_ :ImageControl,
  z: 3000, #描画順序
  id: :img2 do
end

###############################################################################
#汎用コントロール
###############################################################################

#ボタンコントロール
_DEFINE_ :button do |options|
  _CREATE_ :LayoutControl, 
          :x => options[:x] || 0,
          :y => options[:y] || 0,
          :width => 256,
          :height => 256,
          :id=>options[:id] do
    _CREATE_ :ImageControl, 
      :file_path=>"./sozai/button_normal.png", 
      :id=>:normal
    _CREATE_ :ImageControl, 
      :file_path=>"./sozai/button_over.png", 
      :id=>:over, :visible => false
    _CREATE_ :ImageControl, 
      :file_path=>"./sozai/button_key_down.png", 
      :id=>:key_down, :visible => false
    _DEFINE_ :button_func do
      _CHECK_ mouse: [:on_mouse_over] do
        normal  {_SET_ visible: false}
        over    {_SET_ visible: true}
        key_down{_SET_ visible: false}
      end
      _CHECK_ mouse: [:on_mouse_out] do
        normal  {_SET_ visible: true}
        over    {_SET_ visible: false}
        key_down{_SET_ visible: false}
      end
      _CHECK_ mouse: [:on_key_down] do
        normal  {_SET_ visible: false}
        over    {_SET_ visible: false}
        key_down{_SET_ visible: true}
      end
      _CHECK_ mouse: [:on_key_up] do
        normal  {_SET_ visible: false}
        over    {_SET_ visible: true}
        key_down{_SET_ visible: false}
      end
      _END_FRAME_
      button_func
    end
    button_func
  end
end

