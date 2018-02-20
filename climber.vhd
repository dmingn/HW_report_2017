library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use work.types.all;

entity climber is
    port (
        clk  : in  std_logic := '0';
        go   : in  std_logic := '0';
        root : in  std_logic_vector(9 downto 0) := (others => '0');
        hit  : in  std_logic := '0';
        data : in  data_t := ((others => '0'), (others => '0'));
        peak : out std_logic_vector(17 downto 0) := (others => '0');
        len  : out std_logic_vector(7 downto 0) := (others => '0');
        done : out std_logic := '0';
        addr : out std_logic_vector(8 downto 0) := (others => '0')
    );
end climber;

architecture RTL of climber is

    signal root_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal peak_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal len_reg  : std_logic_vector(7 downto 0) := (others => '0');

    signal len_reg_prev : std_logic_vector(7 downto 0) := (others => '0');

    signal valid : std_logic := '0';

begin

    peak <= peak_reg;
    len  <= len_reg;
    done <= '1' when root_reg = 1 else '0';
    addr <= root_reg(9 downto 1);

    process(clk)
    begin
        if rising_edge(clk) then
            valid <= nor_reduce(root_reg(17 downto 10));
            len_reg_prev <= len_reg;
        end if;
    end process;

    process(clk)

        variable root_var : std_logic_vector(17 downto 0) := (others => '0');
        variable peak_var : std_logic_vector(17 downto 0) := (others => '0');
        variable len_var  : std_logic_vector(7 downto 0) := (others => '0');

        variable shift : std_logic_vector(4 downto 0) := (others => '0');

    begin
        if rising_edge(clk) then
            if go = '1' then
                root_var := "00000000" & root;
                peak_var := (others => '0');
                len_var  := (others => '0');
            elsif (valid = '1' and hit = '1' and root_reg /= 1) then
                root_var := "000000000000000001";

                if data.peak < peak_reg then
                    peak_var := peak_reg;
                else
                    peak_var := data.peak;
                end if;

                len_var := len_reg_prev + data.len;
            elsif root_reg /= 1 then
                root_var := root_reg;
                peak_var := peak_reg;
                len_var  := len_reg;

                if root_var(0) = '1' then
                    root_var := (root_var(16 downto 0) & '1') + root_var;

                    if peak_var < root_var then
                        peak_var := root_var;
                    end if;

                    len_var  := len_var + 1;
                end if;

                -- priority encoder
                if root_var(0) = '1' then
                    shift := "00000";
                elsif root_var(1) = '1' then
                    shift := "00001";
                elsif root_var(2) = '1' then
                    shift := "00010";
                elsif root_var(3) = '1' then
                    shift := "00011";
                elsif root_var(4) = '1' then
                    shift := "00100";
                elsif root_var(5) = '1' then
                    shift := "00101";
                elsif root_var(6) = '1' then
                    shift := "00110";
                elsif root_var(7) = '1' then
                    shift := "00111";
                elsif root_var(8) = '1' then
                    shift := "01000";
                elsif root_var(9) = '1' then
                    shift := "01001";
                elsif root_var(10) = '1' then
                    shift := "01010";
                elsif root_var(11) = '1' then
                    shift := "01011";
                elsif root_var(12) = '1' then
                    shift := "01100";
                elsif root_var(13) = '1' then
                    shift := "01101";
                elsif root_var(14) = '1' then
                    shift := "01110";
                elsif root_var(15) = '1' then
                    shift := "01111";
                elsif root_var(16) = '1' then
                    shift := "10000";
                elsif root_var(17) = '1' then
                    shift := "10001";
                else
                    shift := "-----";
                end if;

                -- barrel shifter
                if shift(4) = '1' then
                    root_var := "0000000000000000" & root_var(17 downto 16);
                    len_var  := len_var + 16;
                end if;

                if shift(3) = '1' then
                    root_var := "00000000" & root_var(17 downto 8);
                    len_var  := len_var + 8;
                end if;

                if shift(2) = '1' then
                    root_var := "0000" & root_var(17 downto 4);
                    len_var  := len_var + 4;
                end if;

                if shift(1) = '1' then
                    root_var := "00" & root_var(17 downto 2);
                    len_var  := len_var + 2;
                end if;

                if shift(0) = '1' then
                    root_var := '0' & root_var(17 downto 1);
                    len_var  := len_var + 1;
                end if;
            end if;
        end if;

        root_reg <= root_var;
        peak_reg <= peak_var;
        len_reg  <= len_var;
    end process;

end RTL;
