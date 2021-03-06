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

class RuleShaderControl < Control
  #Imageのキャッシュ機構の簡易実装
  #TODO:キャッシュ操作：一括クリア、番号を指定してまとめて削除など
  @@image_cache = Hash.new
  #キャッシュされていない画像パスが指定されたら読み込む
  @@image_cache.default_proc = ->(hsh, key) {
    hsh[key] = Image.load(key)
  }

  attr_accessor :entity

  #ルールトラジンション：ルール画像設定
  attr_reader :file_path
  def file_path=(file_path)
    @file_path = file_path
    #画像ファイルをキャッシュから読み込んで初期化する
    @entity = TransitionShader.new(@@image_cache[file_path])
  end

  #ルールトランジション：カウンター
  attr_reader :counter
  def counter=(arg)
    @counter = arg
    @entity.g_min =(( @vague + 255).fdiv(255) *
                          @counter - 
                          @vague
                        ).fdiv(255)

    @entity.g_max =( ( @vague + 
                            255
                          ).fdiv(255) *
                          @counter
                        ).fdiv(255)
  end

  #ルールトランジション：曖昧さ
  attr_accessor :vague

  def initialize(options, inner_options, root_control)
    @vague = options[:vague] || 40
    self.file_path = options[:file_path] if options[:file_path]
    self.counter = options[:counter] || 0
    super
  end

  class TransitionShader < DXRuby::Shader
    #ルールトランジションを実行するHLSLスクリプト
    hlsl = <<EOS
    float g_min;
    float g_max;
    float2 scale;
    texture tex0;
    texture tex1;
    sampler Samp0 = sampler_state
    {
     Texture =<tex0>;
    };
    sampler Samp1 = sampler_state
    {
     Texture =<tex1>;
     AddressU = WRAP;
     AddressV = WRAP;
    };

    struct PixelIn
    {
      float2 UV : TEXCOORD0;
    };
    struct PixelOut
    {
      float4 Color : COLOR0;
    };

    PixelOut PS(PixelIn input)
    {
      PixelOut output;
      output.Color = tex2D( Samp0, input.UV );
      output.Color.a *= smoothstep(g_min, g_max, tex2D( Samp1, input.UV * scale ).r );

      return output;
    }

    technique Transition
    {
     pass P0
     {
      PixelShader = compile ps_2_0 PS();
     }
    }
EOS

    #HLSLスクリプトと引数を定義
    @@core = DXRuby::Shader::Core.new(
      hlsl,
      {
        :g_min => :float,
        :g_max => :float,
        :scale => :float, # HLSL側がfloat2の場合は:floatを指定して[Float, Flaot]という形で渡す
        :tex1 => :texture,
      }
    )

    #image：ルール画像のImageオブジェクト(省略でクロスフェード)
    def initialize(image=nil)
      super(@@core, "Transition")
      if image
        @image = image
      else
        @image = DXRuby::Image.new(1, 1, [0,0,0])
      end

      self.g_min = 1.0
      self.g_max = 1.0
      self.tex1   = @image
      self.scale  = [ DXRuby::Window.width.fdiv(@image.width), 
                      DXRuby::Window.height.fdiv(@image.height)
                    ]
    end

  end
end