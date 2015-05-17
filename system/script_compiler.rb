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

module Tsukasa

class ScriptCompiler

  def initialize(argument = nil, &block)
    @option = {}
    @option_stack = []
    @key_name = :commands
    @key_name_stack = []

    if block
      self.instance_exec(argument, &block)
    else
      eval(File.read(argument, encoding: "UTF-8"))
    end
    @script_storage = @option[@key_name] || []
  end

  def impl(command_name, default_class, target, option, sub_options = {}, &block)
    #キー名無しオプションがある場合はコマンド名をキーに設定する
    sub_options[command_name] = option if option != nil

    #ブロックが存在する場合、ブロックを１オプションとして登録する
    if block
      #ネスト用のスタックプッシュ
      @option_stack.push(@option)
      @key_name_stack.push(@key_name)

      #ネスト用の初期化
      @option = {}

      yield

      #ここまでに@optionに:command/:then/:elseなどのハッシュが戻って来ている
      #ex. {:command => [[:text,nil]]}

      #ブロックオプションをオプションリストに追加する
      sub_options.update(@option)

      #スタックポップ
      @key_name = @key_name_stack.pop #ブロックのオプション名
      @option = @option_stack.pop #オプション
    end

    #存在していないキーの場合は配列として初期化する
    @option[@key_name] ||= []

    #コマンドを登録する
    @option[@key_name].push([ command_name,
                              sub_options, 
                              {:target_id => target,
                               :default_class => default_class}])
  end

  #オプション無し
  def self.impl_non_option(command_name, default_class = :Anonymous)
    define_method(command_name) do |target: nil|
      impl(command_name, default_class, target, nil, {})
    end
  end

  #名前なしオプション（１個）
  def self.impl_one_option(command_name, default_class = :Anonymous)
    define_method(command_name) do |option, target: nil|
      impl(command_name, default_class, target, option, {})
    end
  end

  #名前付きオプション群
  def self.impl_options(command_name, default_class = :Anonymous)
    define_method(command_name) do |target: nil, **options |
      impl(command_name, default_class, target, nil, options)
    end
  end

  #ブロック
  def self.impl_block(command_name, default_class = :Anonymous)
    define_method(command_name) do |target: nil,&block|
      impl(command_name, default_class, target, nil) do
        @key_name = :commands; block.call
      end
    end
  end

  #名前無しオプション（１個）＆名前付オプション群＆ブロック
  def self.impl_option_options_block(command_name, default_class = :Anonymous)
    define_method(command_name) do |option , target: nil,**options, &block|
      impl(command_name, default_class, target, option, options )do
        if block; @key_name = :commands; block.call; end
      end
    end
  end

  #プロシージャー登録されたコマンドが宣言された場合にここで受ける
  def method_missing(command_name, target: nil, **options)
    impl(:call_function, :Anonymous, target, command_name, options)
  end

  #次フレームに送る
  impl_non_option :next_frame
  #キー入力待ち
  impl_non_option :pause

  impl_non_option :wait_wake

  impl_options :wake
  impl_non_option :wait_input_key

  #改行
  impl_non_option :line_feed,  :CharContainer
  #改ページ
  impl_non_option :flash,      :CharContainer

  #ボタン制御コマンド群
  #TODO:これは無くても動いて欲しいが、現状だとscript_compilerを通す為に必要
  impl_non_option :normal

  #単一オプションを持つコマンド
  #特定コマンドの終了を待つ
  impl_one_option :wait_command
  #特定フラグの更新を待つ（現状では予めnilが入ってないと機能しない）
  impl_one_option :wait_flag

  #次に読み込むスクリプトファイルの指定
  impl_one_option :next_scenario, :LayoutContainer
  #コントロールの削除
  impl_one_option :dispose,       :LayoutContainer

  impl_non_option :wait_child_controls_idle

  impl_non_option :check_key_push
  impl_one_option :wait_command_with_key_push

  #スリープモードの更新
  impl_one_option :sleep_mode
  #スキップモードの更新
  impl_one_option :skip_mode

  #文字
  impl_one_option :char,         :CharContainer
  #指定フレーム待つ
  impl_one_option :wait
  #インデント設定
  impl_one_option :indent,       :CharContainer
  #文字描画速度の設定
  impl_one_option :delay,        :CharContainer

  #移動
  impl_options :move
  impl_options :move_line
  impl_options :move_line_with_skip

  #フェードトランジション
  impl_options :transition_fade
  impl_options :transition_fade_with_skip
  #フラグ設定
  impl_options :flag
  #ブロックを持つコマンド

  #文字レンダラの指定
  #TODO:これはtext_layer内に動作を限定できないか？
  impl_block :char_renderer,     :CharContainer

  #オプション／サブオプション（省略可）／ブロックを持つコマンド

  #文字列
  impl_one_option :text,         :CharContainer

  impl_option_options_block :change_default_target

  #コントロールの生成
  impl_option_options_block :create
  #コントロール単位でイベント駆動するコマンド群を格納する
  impl_option_options_block :event

  #画像スタック
  impl_option_options_block :graph,               :CharContainer
  #ルビ文字の出力
  impl_option_options_block :rubi_char,           :CharContainer
  #複数ルビ文字列の割り付け
  impl_option_options_block :rubi,                :CharContainer
  #デフォルト
  impl_option_options_block :default_font_config, :CharContainer
  #現在値
  impl_option_options_block :font_config,         :CharContainer
  #現在値をリセット
  impl_option_options_block :reset_font_config,   :CharContainer
  #デフォルト
  impl_option_options_block :default_style_config,:CharContainer
  #現在値
  impl_option_options_block :style_config,        :CharContainer
  #現在値をリセット
  impl_option_options_block :reset_style_config,  :CharContainer
  #レンダリング済みフォントの登録
  impl_option_options_block :map_image_font,      :CharContainer

  #画像の差し替え
  impl_option_options_block :image_change, :ImageControl

  #他の部分でblockという変数を使っているので一応の為変更
  #スクリプト上でもこちらの方が分かりやすいかも
  #impl_block :about  #↓
  def about(target, &block)
    impl(:block, :Anonymous, target, nil, &block)
  end

  #TODO:製作者「仕様変更も歓迎です」
  #target変更は受け付けない(定義した時に扱っているコントロールに登録)
  #自分の子コントロール内ならaboutすればいい
  def define(command_name, &block)
    impl(:define, :Anonymous, nil, command_name, {block: block})
  end

  #制御構造関連
  #if（予約語の為メソッド名差し替え）
  def IF(option, target: nil)
    impl(:if, :Anonymous, target, option) do
      @key_name = :before_then
      yield
    end
  end

  #then（予約語の為メソッド名差し替え）
  def THEN()
    raise if @key_name != :before_then
    @key_name = :then
    yield
    @key_name = :after_then
  end

  def ELSIF(option)
    raise if @key_name != :after_then
    @key_name = :elsif
    impl(:elsif, :Anonymous, nil, option) do
      @key_name = :block
      yield
    end
    @key_name = :after_then
  end

  #else（予約語の為メソッド名差し替え）
  def ELSE()
    raise if @key_name != :after_then
    @key_name = :else
    yield
    @key_name = :after_else
  end

  #while（予約語の為メソッド名差し替え）
  def WHILE(option, target: nil, **sub_options, &block)
    impl(:while, :Anonymous, target, option, sub_options, &block)
  end

  #eval（予約語の為メソッド名差し替え）
  def EVAL(option, target: nil)
    impl(:eval,  :Anonymous, target, option)
  end

=begin
  #command_sleepが無いのでコメントに入れた
  #sleep（予約語の為メソッド名差し替え）
  def sleep_frame
    impl(:sleep, :Anonymous, nil, nil)
  end
=end

  #ヘルパーメソッド群

  def shift()
    return @script_storage.shift
  end

  def empty?
    return @script_storage.empty?
  end
end
end
