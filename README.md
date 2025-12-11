![](Aspose.Words.559829ed-8a52-4db3-87bc-e43523d28890.001.png)

Universidade Federal de Pernambuco     Centro de Informática  

Relatório do Projeto RISC-V Pipeline

Anderson  Vitor  Leoncio  de  Lima  <avll>
Iago Lopes da Silva <ils4>
Pedro Henrique Santana Silva <phss2>
Yago Kauan Mendes Silva <ykms>

Data de entrega: 11/12/25

Sumário:

1 - INTRODUÇÃO

- 1.1: DA ORGANIZAÇÃO DAS IMPLEMENTAÇÕES

2- Implementação das Instruções:

- 2.1: R-types
- 2.2-1: I-types Aritméticas
- 2.2-2: I-types Load
- 2.3: S-types
- 2.4: B-types
- 2.5: J-types
- 2.6: Halt

3 - CONCLUSÕES

- 3.1: Resultados Obtidos
- 3.2: Análise: Os objetivos foram alcançados?

1- Introdução:

O  objetivo  deste  trabalho  consiste  na  implementação  de  instruções  que  não  foram incluídas no projeto original do processador RISC-V. Essas instruções são: JAL, JALR, BNE, BLT, BGE, LB, LH, LBU, SB, SH, SLTI, ADDI, SLLI, SRLI, SRAI, SUB, SLT, XOR, OR, HALT.

1\.1 - Da Organização Das Implementações de Instrução:

Iremos dissertar, nos próximos tópicos deste relatório, acerca da implementação das instruções dadas. Para isso, agrupamos as instruções mencionadas acima quanto aos seus formatos de instrução (ou seja, R-types, I-types, S-types, B-types, U-types e J- types).

Descreveremos depois a instrução de HALT em um tópico separado.

2- Implementação das Instruções:

2\.1- R-types:

As instruções do tipo R implementadas foram: **SUB**, **SLT**, **XOR** e **OR**, além da já existente **ADD**. Essas instruções utilizam dois operandos lidos do banco de registradores e executam operações puramente combinacionais na ALU.

**Arquivos afetados:**

- ALUController.sv
- alu.sv

**Modificações realizadas:**

No módulo **ALUController**, foram adicionadas condições para gerar os códigos de operação (*Operation*) corretos com base nos campos Funct3 e Funct7, dentro do caso onde ALUOp == 2'b10 (correspondente às instruções R-type).

Na **ALU**, cada operação foi mapeada dentro do bloco case(Operation) conforme a tabela abaixo:



|**Instrução**|**Operation**|**Comportamento (Verilog)**|
| - | - | - |
|**SUB**|0110|ALUResult = SrcA - SrcB;|
|**OR**|0001|`ALUResult = SrcA|
|**XOR**|0011|ALUResult = SrcA ^ SrcB;|
|**SLT**|1100|ALUResult = (signed(SrcA) < signed(SrcB)) ? 1 : 0;|

2. **– Instruções do tipo I**
1. **– Instruções Aritméticas Imediatas**

As instruções implementadas nesta categoria foram: **ADDI**, **SLTI**, **SLLI**, **SRLI** e **SRAI**. Essas instruções utilizam um imediato de 12 bits gerado pelo módulo imm\_Gen.sv e selecionam esse valor através do sinal de controle ALUSrc = 1.

**Arquivos afetados:**

- Controller.sv
- ALUController.sv
- alu.sv
- imm\_Gen.sv

**Implementação:**

No módulo **Controller**, as instruções do tipo I (identificadas pelo *opcode* 0010011) foram configuradas  com  os  seguintes  sinais  para  permitir  a  decodificação  correta  via  *Funct3*  e *Funct7*:

- RegWrite = 1
- ALUSrc = 1
- ALUOp = 11

O módulo **ALUController** gera os códigos de operação (*Operations*) específicos conforme a tabela abaixo:

![](Aspose.Words.559829ed-8a52-4db3-87bc-e43523d28890.002.png)

A **ALU** implementa as operações conforme o código *Operation* recebido. Para as instruções de  deslocamento  (*shifts*),  a  execução  ocorre  com  o  operando  SrcB  já  configurado  para receber o valor do imediato.

2. **– Instruções de Load**

As instruções de load implementadas foram: **LB**, **LH** e **LBU**. Embora todas utilizem o mesmo *opcode* (0000011), a interpretação do dado lido depende do campo *Funct3*.

**Arquivos afetados:**

- datamemory.sv
- Memoria32Data.sv
- Controller.sv
- imm\_Gen.sv

**Implementação no hardware:**

O módulo datamemory.sv decodifica o campo *Funct3* para determinar como extrair o dado a partir dos 32 bits recebidos da Memoria32Data. A lógica segue o mapeamento abaixo:



|**Instrução**|**Funct3**|**Comportamento na Extração**|
| - | - | - |
|**LB**|000|Extrai 8 bits e realiza extensão de sinal (*sign-extend*).|
|**LH**|001|Extrai 16 bits e realiza extensão de sinal (*sign-extend*).|
|**LBU**|100|Extrai 8 bits e realiza extensão com zeros (*zero-extend*).|

Além disso, o campo addr[1:0] é utilizado para determinar qual byte ou *halfword* específico será entregue dentro da palavra lida.

3. **– Instruções do tipo S**

As instruções de store implementadas foram: SB (Store Byte) e SH (Store Halfword).

O armazenamento parcial (byte ou halfword) é implementado através de máscaras no módulo datamemory.sv,  que  são  convertidas  em  sinais  de  escrita  Wr[3:0]  utilizados  pela Memoria32Data.

**Máscaras implementadas:**

- **SB:** Ativa apenas 1 bit do vetor Wr.
- **SH:** Ativa 2 bits contíguos do vetor Wr, dependendo do alinhamento do endereço.

Além do controle de escrita, o dado a ser armazenado é deslocado para a posição correta dentro da palavra de 32 bits antes de ser enviado à memória.

4. **– Instruções do tipo B**

As instruções de desvio condicional implementadas foram: **BNE**, **BLT** e **BGE**, somando-se à instrução já existente **BEQ**.

**Arquivos afetados:**

- ALUController.sv
- alu.sv
- BranchUnit.sv

**Implementação:**

A  decisão  de  desvio  é  processada  pela  ALU,  que  compara  os  operandos  e  retorna  um resultado lógico (verdadeiro ou falso) com base no código de operação recebido:



|**Instrução**|**Operation**|**Resultado na ALU**|
| - | - | - |
|**BEQ**|1000|SrcA == SrcB|
|**BNE**|1001|SrcA != SrcB|
|**BGE**|1010|SrcA >= SrcB|
|**BLT**|1011|SrcA < SrcB|

O resultado dessa comparação é enviado para a **BranchUnit**, que determina a seleção do próximo PC (PcSel) através da seguinte lógica:

PcSel = (Branch && ALUResult[0]) || Jump;

- **Se PcSel = 1:** O PC é atualizado para PC + Imm (desvio tomado).
- **Se PcSel = 0:** O PC é atualizado para PC + 4 (fluxo normal).
- A **BranchUnit** também é responsável pelo cálculo físico dos endereços de destino (PC + 4 e PC + Imm).
5. **– Instruções do tipo J**

As instruções de salto incondicional implementadas foram: **JAL** e **JALR**.

**Arquivos afetados:**

- Controller.sv
- Datapath.sv
- BranchUnit.sv
- imm\_Gen.sv

**Implementação do JAL:**

- Utiliza um imediato do tipo **UJ**, montado corretamente no módulo imm\_Gen.sv.
- O endereço de retorno salvo no registrador de destino (*rd*) é PC + 4 (com RegWrite = 1).
- O próximo PC é calculado como PC + Imm.

**Implementação do JALR:**

- Utiliza um imediato do tipo **I**.
- A **BranchUnit** seleciona o ALUResult como o próximo endereço do PC sempre que o sinal de controle Jalr = 1 estiver ativo.
6. **–  HALT**

Esse tópico será dedicado exclusivamente à implementação da instrução de HALT.

1. **Mudanças no módulo “Controller”:** Foi adicionado um novo sinal de controle, o de “Halt\_com”, ou “Halt Command”. Para implementá-lo, só criamos mais um sinal de output da unidade de Controller, e fizemos que esse sinal de controle recebesse nível lógico '1' exclusivamente caso o Opcode da instrução fosse igual ao da instrução de Halt.
1. **Alterações na branch unit:** Passamos o sinal de Halt\_com como um dos inputs para a Branch Unit, algo que é facilmente implementado na Branch Unit mas que tem implicações maiores para o Datapath e os registradores de Pipeline, conforme será mostrado em breve. Depois disso, fazemos com que, na seleção de Branch, caso Halt\_com tenha nível lógico '1' (ou seja, caso tenhamos uma instrução de Halt), devemos sempre selecionar PC\_four - 4. Ou seja, PC + 4 - 4 = PC + 0. Isso se deve ao fato que esse branch trava a execução em um loop infinito na qual somente a instrução de HALT (que não faz nada além desse branch) é executada, não permitindo que o resto do programa execute, conforme queríamos que fosse. A implementação dessa lógica na Branch Unit é mostrada pela imagem abaixo, que já foi mostrada anteriormente neste relatório.

   ![](Aspose.Words.559829ed-8a52-4db3-87bc-e43523d28890.003.png)

3. **Alterações nos registradores de Pipeline:** Aqui, basta modificar os parâmetros do registrador ‘B’ de modo que ele também possa armazenar o sinal de controle “Halt\_Com”, algo facilmente implementado no módulo ‘RegPack’.
3. **Alterações no Datapath:** Aqui, devemos passar como parâmetro no bloco ‘Always’ no qual modificamos o registrador de pipeline ‘B’ o sinal de controle de Halt\_com. Devemos também passá-lo como parâmetro na Branch Unit, e como um dos inputs para o módulo de Datapath.
3. **Alterações no Módulo ‘Risc-V’:** Precisamos adicionar Halt\_com como uma variável, e colocar este entre os inputs do módulo de ‘Datapath’, além, é claro, de como output para o módulo de ‘Controller’.

   **3 – Dos Resultados Obtidos**

   A partir da implementação das instruções listadas na Seção 2, foram realizados testes de simulação  no  ModelSim  para  verificar  o  correto  funcionamento  do  processador  RISC-V pipelined. As simulações contemplaram:

- Execução de instruções aritméticas e lógicas (R-types e I-types)
- Acesso à memória por meio de loads e stores
- Desvios condicionais (B-types)
- Instruções de salto (JAL e JALR)
- Funcionamento do pipeline com forwarding e hazard detection
- Atualização do PC e propagação de sinais entre estágios

Os resultados observados confirmam que:

- Instruções R-type (SUB, SLT, XOR, OR)

O  ALUController  gerou  corretamente  o  código  de  operação  para  cada  instrução.  A  ALU produziu os resultados esperados, sendo possível verificar no waveform que os valores lidos do banco de registradores foram combinados de acordo com a operação definida por Funct3 e Funct7, resultando em escrita correta no estágio WB.

- Instruções I-type aritméticas (ADDI, SLTI, SLLI, SRLI, SRAI)

O  imediato  foi  estendido  corretamente  pelo  módulo  imm\_Gen.sv,  e  a  ALU  executou  as operações  com  precisão.  As  instruções  de  deslocamento  operaram  conforme  o  valor  de shamt, e o sinal RegWrite foi corretamente ativado ao final do pipeline.

- Instruções de Load (LB, LH, LBU)

As  simulações  demonstraram  que  a  memória  converteu  adequadamente  os  dados  lidos, aplicando *sign-extend* ou *zero-extend* conforme o tipo da instrução. A indexação por addr[1:0] apresentou  comportamento  coerente  com  a  extração  de  bytes  e  halfwords,  validando  o mecanismo de acesso parcial à memória.

- Instruções de Store (SB, SH)

O módulo de memória aplicou corretamente as máscaras de escrita (write strobes), ativando somente os bytes correspondentes. Os dados foram armazenados corretamente nas posições de memória, sem sobrescrever outros bytes adjacentes.

- Instruções de Desvio (BNE, BLT, BGE)

A  ALU  comparou  corretamente  os  registradores  de  origem  e  produziu  valores  binários esperados  para  tomada  ou  não  do  desvio.  O  sinal  PcSel  foi  ativado  apenas  quando  as condições de desvio eram satisfeitas. O cálculo de endereço feito pela BranchUnit mostrou-se consistente com o imediato do tipo B.

- Instruções de Salto (JAL e JALR)

As simulações de ambos os saltos mostraram atualização correta do PC para PC + Imm, além da escrita de PC + 4 no registrador de destino (rd), validando tanto o fluxo do salto quanto  o  mecanismo  de  *link*.  No  caso  de  JALR,  foi  observada  a  limpeza  do  bit  menos significativo, conforme especificação do padrão RISC-V.

- Pipeline: propagação correta pelos estágios IF/ID/EX/MEM/WB

Os registradores de pipeline (A, B, C, D) armazenaram e propagaram instruções e sinais de controle corretamente. Ao longo das simulações, foi possível observar instruções diferentes sendo  processadas  simultaneamente  em  estágios  distintos,  demonstrando  a  operação paralela típica de um pipeline funcional.

- Forwarding

Em situações de dependência de dados entre instruções consecutivas, os sinais FAmuxSel e FBmuxSel foram corretamente acionados, permitindo que resultados mais recentes fossem encaminhados para a ALU sem necessidade de stalls. Os valores exibidos no waveform confirmaram que o bypass estava funcionando conforme previsto.

- Hazard Detection (load-use stall)

Nos casos em que uma instrução dependia de um valor carregado imediatamente antes, o módulo  de  Hazard  Detection  aplicou  corretamente  o  stall,  mantendo  IF/ID  constante  e inserindo  o  NOP  em  ID/EX.  Esse  comportamento  foi  confirmado  pela  ausência  de inconsistências nos registros e na execução subsequente.

**3.1 – Conclusão**

Com base nos testes realizados, é possível concluir que o processador RISC-V desenvolvido cumpre  com  sucesso  as  funcionalidades  propostas  no  projeto.  Todas  as  instruções implementadas  —  R-types,  I-types,  loads,  stores,  branches  e  jumps  —  apresentaram comportamento coerente com a especificação do conjunto RV32I. A Unidade de Controle, a Unidade de Branch, o Geração de Imediatos e a ALU trabalharam de forma integrada e consistente.

Além disso:

- O pipeline permitiu execução paralela correta.
- O forwarding eliminou hazards de dados não relacionados a loads.
- A detecção de hazards aplicou stalls apenas quando estritamente necessário.
- A  memória  apresentou  funcionamento  adequado  tanto  para  leituras  como  para escritas parciais.

Dessa forma, o processador produzido mostrou-se estável, funcional e capaz de executar corretamente o subconjunto de instruções esperado, validando o projeto desenvolvido pela equipe.














