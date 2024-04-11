--  https://ghdl.readthedocs.io/en/stable/using/QuickStartGuide.html
--  A testbench has no ports.
-- Kevin Ulis
-- CPE 487, Simulation Exercise 1
-- I pledge my Honor that I have abided by the Stevens Honor System.
entity adder_tb is
end adder_tb;

architecture behav of adder_tb is
  --  Declaration of the component that will be instantiated.
  component adder
    port (i0, i1 : in bit; ci : in bit; s : out bit; co : out bit);
  end component;

  --  Specifies which entity is bound with the component.
  for adder_0, adder_1, adder_2, adder_3: adder use entity work.adder;
  signal A0,A1,A2,A3,B0,B1,B2,B3,ci,s0,s1,s2,s3,co0,co1,co2,co3 : bit;
begin
  --  Component instantiation.
  adder_0: adder port map (i0 => A0, i1 => B0, ci => ci,
                           s => s0, co => co0);
  adder_1: adder port map (i0 => A1, i1 => B1, ci => co0,
                           s => s1, co => co1);
  adder_2: adder port map (i0 => A2, i1 => B2, ci => co1,
                           s => s2, co => co2);
  adder_3: adder port map (i0 => A3, i1 => B3, ci => co2,
                           s => s3, co => co3);

  --  This process does the real job.
  process
    type pattern_type is record
      --  The inputs of the adder.
      i0, i1, ci : bit;
      --  The expected outputs of the adder.
      s, co : bit;
    end record;
    --  The patterns to apply.
    type pattern_array is array (natural range <>) of pattern_type;
    constant patterns : pattern_array :=
      (('0', '0', '0', '0', '0'),
       ('0', '0', '1', '1', '0'),
       ('0', '1', '0', '1', '0'),
       ('0', '1', '1', '0', '1'),
       ('1', '0', '0', '1', '0'),
       ('1', '0', '1', '0', '1'),
       ('1', '1', '0', '0', '1'),
       ('1', '1', '1', '1', '1'));
  begin
    --  Check each pattern.
    A1<='1';
    A2<='1';
    A3<='1';
    for i in patterns'range loop
      --  Set the inputs.
      A0 <= patterns(i).i0;
      B0 <= patterns(i).i1;
      ci <= patterns(i).ci;
      --  Wait for the results.
      wait for 1 ns;
      --  Check the outputs.
      assert s0 = patterns(i).s
        report "bad sum value" severity error;
      assert s1 = patterns(i).s
        report "bad sum value" severity error;
      assert s2 = patterns(i).s
        report "bad sum value" severity error;
      assert s3 = patterns(i).s
        report "bad sum value" severity error;
      assert co0 = patterns(i).co
        report "bad carry out value" severity error;
      assert co1 = patterns(i).co
        report "bad carry out value" severity error;
      assert co2 = patterns(i).co
        report "bad carry out value" severity error;
      assert co3 = patterns(i).co
        report "bad carry out value" severity error;
    end loop;
    assert false report "end of test" severity note;
    --  Wait forever; this will finish the simulation.
    wait;
  end process;
end behav;
