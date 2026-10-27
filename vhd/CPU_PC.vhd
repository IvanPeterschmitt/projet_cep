library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD,
        S_SLL,
        S_AUIPC,
        S_AND,
        S_ARITH_LOGIC,
        S_OR,
        S_XOR,
        S_SUB,
        S_ORI,
        S_ARITH_LOGIC_I,
        S_ANDI,
        S_XORI,
        S_SRL,
        S_SRA,
        S_SRAI,
        S_SLLI,
        S_SRLI,
        S_INST_SAUTS,
        S_SAUT,
        S_BEQ,
        S_BNE,
        S_BLT,
        S_BGE,
        S_BLTU,
        S_BGEU,
        S_SLT,
        S_SLTU,
        S_SLTI,
        S_SLTIU,
        S_Pre_LOAD,
        S_LOAD,
        S_LOAD_SORTIE,
        S_Pre_STORE,
        S_STORE,
        S_JAL,
        S_JALR,
        S_JALR_Pre_Fetch,
        S_STORE_SORTIE
    );

    signal state_d, state_q : State_type;


begin

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.ALU_op            <= ALU_plus;
        cmd.LOGICAL_op        <= LOGICAL_xor;
        cmd.ALU_Y_sel         <= ALU_Y_immI;

        cmd.SHIFTER_op        <= SHIFT_ll;
        cmd.SHIFTER_Y_sel     <= SHIFTER_Y_rs2;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= RF_SIZE_word;
        cmd.RF_SIGN_enable    <= '0';
        cmd.DATA_sel          <= DATA_from_alu;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= PC_from_pc;

        cmd.PC_X_sel          <= PC_X_pc;
        cmd.PC_Y_sel          <= PC_Y_cst_x04;

        cmd.TO_PC_Y_sel       <= TO_PC_Y_cst_x04;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= AD_Y_immI;

        cmd.IR_we             <= '0';

        cmd.ADDR_sel          <= ADDR_from_pc;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd.cs.CSR_we            <= CSR_none;

        cmd.cs.TO_CSR_sel        <= TO_CSR_from_rs1;
        cmd.cs.CSR_sel           <= CSR_from_mip;
        cmd.cs.MEPC_sel          <= MEPC_from_pc;

        cmd.cs.MSTATUS_mie_set   <= '0';
        cmd.cs.MSTATUS_mie_reset <= '0';

        cmd.cs.CSR_WRITE_mode    <= WRITE_mode_simple;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue 
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>
                -- On peut aussi utiliser un case, ...
                -- et ne pas le faire juste pour les branchements et auipc
                if status.IR(6 downto 0) = "0010011" then
                    -- Instruction arithmétique et logique avec immédiat de type I
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ARITH_LOGIC_I;
                elsif status.IR(6 downto 0) = "0110011" then
                    -- Instruction arithmétiques et logiques
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_ARITH_LOGIC;
                elsif status.IR(6 downto 0) = "0110111" then
                    -- LUI
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LUI;
                elsif status.IR(6 downto 0) = "0010111" then
                    -- AUIPC
                    state_d <= S_AUIPC;
                elsif status.IR(6 downto 0) = "1100011" then
                    -- Instructions de saut
                    state_d <= S_INST_SAUTS;
                elsif status.IR(6 downto 0) = "1101111" then
                    -- JAL
                    state_d <= S_JAL;
                elsif status.IR(6 downto 0) = "1100111" then
                    -- JALR
                    state_d <= S_JALR;
                elsif status.IR(6 downto 0) = "0000011" then
                    -- Instruction de chargement depuis la mémoire
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_Pre_LOAD;
                elsif status.IR(6 downto 0) = "0100011" then
                    -- Instructions de sauvegarde en mémoire
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_Pre_STORE;
                else
                    state_d <= S_Error; -- Pour détecter les ratés du décodage
                end if;



                

---------- Instructions avec immediat de type U ----------

            when S_AUIPC =>
                -- rd <= immU + pc
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.PC_X_sel <= PC_X_pc;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- incrémentation de pc
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;

            when S_LUI =>
                -- rd <- ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

---------- Instructions arithmétiques et logiques avec immédiat I ----------
            when S_ARITH_LOGIC_I =>
                if status.IR(14 downto 12) = "000" then
                    -- ADDI
                    state_d <= S_ADDI;
                elsif status.IR(14 downto 12) = "001" then
                    -- SLLI
                    state_d <= S_SLLI;
                elsif status.IR(14 downto 12) = "010" then
                    -- SLTI
                    state_d <= S_SLTI;
                elsif status.IR(14 downto 12) = "011" then
                    -- SLTIU
                    state_d <= S_SLTIU;
                elsif status.IR(14 downto 12) = "100" then
                    -- XORI
                    state_d <= S_XORI;
                elsif status.IR(14 downto 12) = "101" then
                    if status.IR(30) = '0' then
                        -- SRLI
                        state_d <= S_SRLI;
                    elsif status.IR(30) = '1' then
                        -- SRAI
                        state_d <= S_SRAI;
                    end if;
                elsif status.IR(14 downto 12) = "110" then
                    -- ORI
                    state_d <= S_ORI;
                elsif status.IR(14 downto 12) = "111" then
                    -- ANDI
                    state_d <= S_ANDI;
                else
                    state_d <= S_Error; -- Pour détecter les ratés du décodage
                end if;

            when S_ADDI =>
                -- rd <- rs1 + immI
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_ORI =>
                -- rd <- rs1 ori immI
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_ANDI =>
                -- rd <- rs1 ori immI
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_XORI =>
                -- rd <- rs1 ori immI
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SRAI =>
                -- 
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SLLI =>
                -- 
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SRLI =>
                -- 
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SLTI =>
                -- rs1 < rs2
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SLTIU =>
                -- rs1 < rs2
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

---------- Instructions arithmétiques et logiques ----------

            when S_ARITH_LOGIC =>
                if status.IR(14 downto 12) = "000" then
                    if status.IR(30) = '0' then
                        -- ADD
                        state_d <= S_ADD;
                    elsif status.IR(30) = '1' then
                        -- SUB
                        state_d <= S_SUB;
                    end if;
                elsif status.IR(14 downto 12) = "001" then
                    -- SLL
                    state_d <= S_SLL;
                elsif status.IR(14 downto 12) = "010" then
                    -- SLT
                    state_d <= S_SLT;
                elsif status.IR(14 downto 12) = "011" then
                    -- SLTU
                    state_d <= S_SLTU;
                elsif status.IR(14 downto 12) = "100" then
                    -- XOR
                    state_d <= S_XOR;
                elsif status.IR(14 downto 12) = "101" then
                    if status.IR(30) = '0' then
                        -- SRL
                        state_d <= S_SRL;
                    elsif status.IR(30) = '1' then
                        -- SRA
                        state_d <= S_SRA;
                    end if;
                elsif status.IR(14 downto 12) = "110" then
                    -- OR
                    state_d <= S_OR;
                elsif status.IR(14 downto 12) = "111" then
                    -- AND
                    state_d <= S_AND;
                else
                    state_d <= S_Error; -- Pour détecter les ratés du décodage
                end if;


            when S_ADD =>
                -- rd <- rs1 + rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_plus;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SUB =>
                -- rd <- rs1 + rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_minus;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SLL =>
                -- 
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;
            
            when S_AND =>
                -- rd <= rs1 and rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_OR =>
                -- rd <= rs1 or rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_XOR =>
                -- rd <= rs1 xor rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SRL =>
                -- 
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SRA =>
                -- 
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SLT =>
                -- rs1 < rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;

            when S_SLTU =>
                -- rs1 < rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                -- mem[PC]
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                -- next state
                state_d <= S_Fetch;


---------- Instructions de saut ----------
            when S_INST_SAUTS =>
                case status.IR(14 downto 12) is
                    when "000" | "001" | "100" | "101" | "110" | "111" =>
                        cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                        if status.JCOND = true then
                            cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                            cmd.PC_sel <= PC_from_pc;
                            cmd.PC_we <= '1';
                            -- next state
                            state_d <= S_Pre_Fetch;
                        else 
                            cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                            cmd.PC_sel <= PC_from_pc;
                            cmd.PC_we <= '1';
                            -- next state
                            state_d <= S_Pre_Fetch;
                        end if;
                    when others =>
                        state_d <= S_Error;
                end case;

            when S_JAL =>
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.PC_X_sel <= PC_X_pc;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                --next state
                state_d <= S_Pre_Fetch;

            when S_JALR =>
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.PC_X_sel <= PC_X_pc;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.PC_sel <= PC_from_alu;
                cmd.PC_we <= '1';
                --next state
                state_d <= S_Pre_Fetch;
                

---------- Instructions de chargement à partir de la mémoire ----------
            when S_Pre_LOAD =>
                case status.IR(14 downto 12) is 
                    when "010" | "000" | "100" | "001" | "101" =>
                        cmd.AD_Y_sel <= AD_Y_immI;
                        cmd.AD_we <= '1';
                        state_d <= S_LOAD;
                    when others =>
                        state_d <= S_Error; -- Pour détecter les ratés du décodage
                end case;

            when S_LOAD =>

                if status.IR(14 downto 12) = "010" then
                    -- LW
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                elsif status.IR(14 downto 12) = "000" or
                      status.IR(14 downto 12) = "100" then
                    -- LB, LBU
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                elsif status.IR(14 downto 12) = "001" or
                      status.IR(14 downto 12) = "101"then
                    -- LH, LHU
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                end if;    
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                -- next state
                state_d <= S_LOAD_SORTIE;


            when S_LOAD_SORTIE =>

                if status.IR(14 downto 12) = "010" then
                    -- LW
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                    cmd.RF_SIGN_enable <= '1';
                elsif status.IR(14 downto 12) = "000" then
                    -- LB
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                    cmd.RF_SIGN_enable <= '1';
                elsif status.IR(14 downto 12) = "100" then
                    -- LBU
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                    cmd.RF_SIGN_enable <= '0';
                elsif status.IR(14 downto 12) = "001" then
                    -- LH
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                    cmd.RF_SIGN_enable <= '1';
                elsif status.IR(14 downto 12) = "101" then
                    -- LHU
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                    cmd.RF_SIGN_enable <= '0';
                end if;
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;

                

---------- Instructions de sauvegarde en mémoire ----------
            when S_Pre_STORE =>
                case status.IR(14 downto 12) is
                    when "000" | "010" | "001" =>
                    cmd.AD_Y_sel <= AD_Y_immS;
                    cmd.AD_we <= '1';
                    state_d <= S_STORE;
                    when others =>
                        state_d <= S_Error; -- Pour détecter les ratés du décodage
                end case;

            when S_STORE =>
                if status.IR(14 downto 12) = "010" then
                    -- SW
                    cmd.RF_SIZE_sel <= RF_SIZE_word;
                elsif status.IR(14 downto 12) = "000" then
                    -- SB
                    cmd.RF_SIZE_sel <= RF_SIZE_byte;
                elsif status.IR(14 downto 12) = "001" then
                    -- SH
                    cmd.RF_SIZE_sel <= RF_SIZE_half;
                end if;
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_we <= '1';
                cmd.mem_ce <= '1';
                state_d <= S_Pre_Fetch;

---------- Instructions d'accès aux CSR ----------

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
