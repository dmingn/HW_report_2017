library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

entity collatz is
    port (
        clk       : in  std_logic := '0';
        clk_count : out std_logic_vector(31 downto 0) := (others => '0');
        top4      : out chains4_t := (others => ((others => '0'), (others => '0'), (others => '0')))
    );
end collatz;

architecture RTL of collatz is

    component climber is
        port (
            clk  : in  std_logic;
            go   : in  std_logic;
            root : in  std_logic_vector(9 downto 0);
            hit  : in  std_logic;
            data : in  data_t;
            peak : out std_logic_vector(17 downto 0);
            len  : out std_logic_vector(7 downto 0);
            done : out std_logic;
            addr : out std_logic_vector(8 downto 0)
        );
    end component;

    component sorter is
        port (
            clk   : in  std_logic;
            chain : in  chain_t;
            top4  : out chains4_t
        );
    end component;

    component ram is
        port (
            clk          : in  std_logic;
            write_enable : in  std_logic;
            addr         : in  std_logic_vector(8 downto 0);
            data_in      : in  data_t;
            hit          : out std_logic;
            data_out     : out data_t
        );
    end component;

    signal clk_count_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal alldone : std_logic := '0';

    signal go   : std_logic := '1';
    signal root : std_logic_vector(8 downto 0) := (others => '0');
    signal peak : std_logic_vector(17 downto 0) := (others => '0');
    signal len  : std_logic_vector(7 downto 0) := (others => '0');
    signal done : std_logic_vector(1 downto 0) := (others => '0');

    signal root_chain : std_logic_vector(9 downto 0) := (others => '0');

    signal chain_reg : chain_t := ((others => '0'), (others => '0'), (others => '0'));

    signal write_enable  : std_logic := '0';
    signal addr_chain    : std_logic_vector(8 downto 0) := (others => '0');
    signal addr_ram      : std_logic_vector(8 downto 0) := (others => '0');
    signal hit           : std_logic := '0';
    signal data_in       : data_t := ((others => '0'), (others => '0'));
    signal data_out      : data_t := ((others => '0'), (others => '0'));

begin

    climber_p : climber port map(
        clk  => clk,
        go   => go,
        root => root_chain,
        hit  => hit,
        data => data_out,
        peak => peak,
        len  => len,
        done => done(0),
        addr => addr_chain
    );

    sorter_p : sorter port map (
        clk   => clk,
        chain => chain_reg,
        top4  => top4
    );

    ram_p : ram port map (
        clk          => clk,
        write_enable => write_enable,
        addr         => addr_ram,
        data_in      => data_in,
        hit          => hit,
        data_out     => data_out
    );

    clk_count <= clk_count_reg;
    root_chain <= root & '1';
    data_in <= (peak, len);
    addr_ram <= root - 1 when write_enable = '1' else addr_chain;

    process(clk, alldone)
    begin
        if rising_edge(clk) and alldone = '0' then
            clk_count_reg <= clk_count_reg + 1;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (done = "01" and alldone = '0') then
                chain_reg <= (root & '1', peak, len);
                write_enable <= '1';
                root <= root + 1;

                if root >= 511 then
                    alldone <= '1';
                else
                    go <= '1';
                end if;
            else
                write_enable <= '0';
                go <= '0';
            end if;

            done(1) <= done(0);
        end if;
    end process;

end RTL;
