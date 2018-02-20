library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.types.all;

entity ram is
    port (
        clk          : in  std_logic := '0';
        write_enable : in  std_logic := '0';
        addr         : in  std_logic_vector(8 downto 0) := (others => '0');
        data_in      : in  data_t := ((others => '0'), (others => '0'));
        hit          : out std_logic := '0';
        data_out     : out data_t := ((others => '0'), (others => '0'))
    );
end ram;

architecture RTL of ram is

    component ram_ip
        port (
            address : in  std_logic_vector(8 downto 0);
            clock   : in  std_logic;
            data    : in  std_logic_vector(26 downto 0);
            wren    : in  std_logic;
            q       : out std_logic_vector(26 downto 0)
        );
    end component;

    signal data : std_logic_vector(26 downto 0) := (others => '0');
    signal q    : std_logic_vector(26 downto 0) := (others => '0');

begin

    ram_ip_p : ram_ip port map (
        address => addr,
        clock   => clk,
        data    => data,
        wren    => write_enable,
        q       => q
    );

    data <= write_enable & data_in.peak & data_in.len;

    hit <= q(26);
    data_out.peak <= q(25 downto 8);
    data_out.len  <= q(7 downto 0);

end RTL;
