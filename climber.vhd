library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

entity climber is
    port (
        clk  : in  std_logic := '0';
        go   : in  std_logic := '0';
        root : in  std_logic_vector(9 downto 0) := (others => '0');
        peak : out std_logic_vector(17 downto 0) := (others => '0');
        len  : out std_logic_vector(7 downto 0) := (others => '0');
        done : out std_logic := '0'
    );
end climber;

architecture RTL of climber is

    signal root_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal peak_reg : std_logic_vector(17 downto 0) := (others => '0');
    signal len_reg  : std_logic_vector(7 downto 0) := (others => '0');

begin

    peak <= peak_reg;
    len  <= len_reg;
    done <= '1' when root_reg = 1 else '0';

    process(clk)

        variable root_var : std_logic_vector(17 downto 0) := (others => '0');
        variable peak_var : std_logic_vector(17 downto 0) := (others => '0');
        variable len_var  : std_logic_vector(7 downto 0) := (others => '0');

    begin
        if rising_edge(clk) then
            if go = '1' then
                root_var := "00000000" & root;
                peak_var := (others => '0');
                len_var  := (others => '0');
            else
                root_var := root_reg;
                peak_var := peak_reg;
                len_var  := len_reg;

                if root_var(0) = '1' then
                    root_var := (root_var(16 downto 0) & '1') + root_var;

                    if peak_var < root_var then
                        peak_var := root_var;
                    end if;

                    root_var := '0' & root_var(17 downto 1);
                    len_var  := len_var + 2;
                elsif root_var(1 downto 0) = "00" then
                    root_var := "00" & root_var(17 downto 2);
                    len_var  := len_var + 2;
                else
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
