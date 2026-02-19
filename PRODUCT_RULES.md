# Product Rules (WhatsApp Atendimento)

## Objetivo

Garantir atendimento consistente e rastreavel no Chatwoot via WhatsApp Cloud API.

## Regras Basicas

- Toda mensagem inbound deve gerar conversa ou anexar na conversa existente.
- Priorizar contexto da conversa atual antes de responder.
- Mensagens fora de texto devem ter fallback claro.
- Nao prometer preco/estoque sem fonte de verdade.

## Regras de Resposta

- Tom objetivo, educado e curto.
- Confirmar dados criticos (produto, quantidade, endereco) antes de fechar pedido.
- Em caso de erro, reconhecer e orientar proximo passo.

## Escalacao Humana

Escalar para agente humano quando:
- cliente pedir explicitamente
- conflito de pagamento/entrega
- duvida fora do escopo de catalogo

## Telemetria Minima

- tempo medio de primeira resposta
- taxa de conversa concluida
- taxa de handoff humano
- taxa de erro por fluxo

## Nao Funcionais

- logs com correlation id
- idempotencia em eventos webhook
- reprocessamento seguro de jobs
