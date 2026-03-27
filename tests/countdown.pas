program Countdown;
const
  start = 10;
var
  n: integer;
  done: boolean;
begin
  n := start;
  done := false;
  while not done do
  begin
    writeln(n);
    n := n - 1;
    if n = 0 then
      done := true
  end;
  writeln(n)
end.
