library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use work.types.all;

entity sorter is
    port (
        clk   : in  std_logic := '0';
        chain : in  chain_t := ((others => '0'), (others => '0'), (others => '0'));
        top4  : out chains4_t := (others => ((others => '0'), (others => '0'), (others => '0')))
    );
end sorter;

architecture RTL of sorter is

    signal top4_reg : chains4_t := (others => ((others => '0'), (others => '0'), (others => '0')));

begin

    top4 <= top4_reg;

    process(clk)

        variable chains : chains5_t := (others => ((others => '0'), (others => '0'), (others => '0')));
        variable flags : std_logic_vector(3 downto 0) := (others => '0');

    begin
        if rising_edge(clk) then
            for i in 0 to 3 loop
                chains(i) := top4_reg(i);
            end loop;
            chains(4) := chain;

            flags := "0000";
            for i in 0 to 3 loop
                if chains(i).peak = chains(4).peak then
                    if chains(i).len < chains(4).len then
                        chains(i).root := chains(4).root;
                        chains(i).len := chains(4).len;
                    end if;

                    flags(i) := '1';
                end if;
            end loop;

            -- bubble sort
            for i in 4 downto 1 loop
                if chains(i-1).peak < chains(i).peak and nor_reduce(flags) = '1' then
                    -- xor swap
                    chains(i).root   := chains(i-1).root xor chains(i).root;
                    chains(i-1).root := chains(i-1).root xor chains(i).root;
                    chains(i).root   := chains(i-1).root xor chains(i).root;
                    chains(i).peak   := chains(i-1).peak xor chains(i).peak;
                    chains(i-1).peak := chains(i-1).peak xor chains(i).peak;
                    chains(i).peak   := chains(i-1).peak xor chains(i).peak;
                    chains(i).len   := chains(i-1).len xor chains(i).len;
                    chains(i-1).len := chains(i-1).len xor chains(i).len;
                    chains(i).len   := chains(i-1).len xor chains(i).len;
                end if;
            end loop;

            for i in 0 to 3 loop
                top4_reg(i) <= chains(i);
            end loop;
        end if;
    end process;

end RTL;
