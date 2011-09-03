# encoding: UTF-8
require 'sax-machine'

module Correios
  module Frete
    class Servico
      include SAXMachine
      
      # Services according to:
      # http://www.correios.com.br/webServices/PDF/SCPP_manual_implementacao_calculo_remoto_de_precos_e_prazos.pdf
      
      AVAILABLE_SERVICES = {
        "41106" => { :type => :pac                          , :name => "PAC sem contrato"                 },
        "40010" => { :type => :sedex                        , :name => "SEDEX sem contrato"               },
        "40045" => { :type => :sedex_a_cobrar               , :name => "SEDEX a Cobrar, sem contrato"     },
        "40126" => { :type => :sedex_a_cobrar_com_contrato  , :name => "SEDEX a Cobrar, com contrato"     },
        "40215" => { :type => :sedex_10                     , :name => "SEDEX 10, sem contrato"           },
        "40290" => { :type => :sedex_hoje                   , :name => "SEDEX Hoje, sem contrato"         },
        "40096" => { :type => :sedex_com_contrato_1         , :name => "SEDEX com contrato"               },
        "40436" => { :type => :sedex_com_contrato_2         , :name => "SEDEX com contrato"               },
        "40444" => { :type => :sedex_com_contrato_3         , :name => "SEDEX com contrato"               },
        "40568" => { :type => :sedex_com_contrato_4         , :name => "SEDEX com contrato"               },
        "40606" => { :type => :sedex_com_contrato_5         , :name => "SEDEX com contrato"               },
        "81019" => { :type => :e_sedex_com_contrato         , :name => "e-SEDEX, com contrato"            },
        "41068" => { :type => :pac_com_contrato             , :name => "PAC com contrato"                 },
        "81868" => { :type => :e_sedex_com_contrato_grupo_1 , :name => "(Grupo 1) e-SEDEX, com contrato"  },
        "81833" => { :type => :e_sedex_com_contrato_grupo_2 , :name => "(Grupo 2) e-SEDEX, com contrato"  },
        "81850" => { :type => :e_sedex_com_contrato_grupo_3 , :name => "(Grupo 3) e-SEDEX, com contrato"  }
      }

      element :Codigo, :as => :codigo
      element :Valor, :as => :valor
      element :PrazoEntrega, :as => :prazo_entrega
      element :ValorMaoPropria, :as => :valor_mao_propria
      element :ValorAvisoRecebimento, :as => :valor_aviso_recebimento
      element :ValorValorDeclarado, :as => :valor_valor_declarado
      element :EntregaDomiciliar, :as => :entrega_domiciliar
      element :EntregaSabado, :as => :entrega_sabado
      element :Erro, :as => :erro
      element :MsgErro, :as => :msg_erro
      attr_reader :tipo, :nome

      alias_method :original_parse, :parse

      def parse(xml_text)
        original_parse xml_text

        if AVAILABLE_SERVICES[codigo]
          @tipo = AVAILABLE_SERVICES[codigo][:type]
          @nome = AVAILABLE_SERVICES[codigo][:name]
        end

        cast_to_float! :valor, :valor_mao_propria, :valor_aviso_recebimento, :valor_valor_declarado
        cast_to_int! :prazo_entrega
        cast_to_boolean! :entrega_domiciliar, :entrega_sabado
        self
      end

      def success?
        erro == "0"
      end
      alias sucesso? success?

      def error?
        !success?
      end
      alias erro? error?

      def self.code_from_type(type)
        # I don't use select method for Ruby 1.8.7 compatibility.
        AVAILABLE_SERVICES.map { |key, value| key if value[:type] == type }.compact.first
      end

      private

      def cast_to_float!(*attributes)
        attributes.each do |attr|
          instance_variable_set("@#{attr}", send(attr).to_s.gsub("," ,".").to_f)
        end
      end

      def cast_to_int!(*attributes)
        attributes.each do |attr|
          instance_variable_set("@#{attr}", send(attr).to_i)
        end
      end

      def cast_to_boolean!(*attributes)
        attributes.each do |attr|
          instance_variable_set("@#{attr}", send(attr) == "S")
        end
      end
    end
  end
end
