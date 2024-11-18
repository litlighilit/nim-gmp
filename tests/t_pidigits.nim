## pidigits from computer language benchmark game
## ported from original c version by Mr Ledrug, see:
## http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=gcc&id=1

import gmp
import gmp/utils

import std/strutils
import std/os
import std/streams
import std/unittest

var 
  tmp1, tmp2, acc, den, num: mpz_t

proc extract_digit(nth: culong): culong =
  # joggling between tmp1 and tmp2, so GMP won't have to use temp buffers
  mpz_mul_ui(tmp1, num, nth)
  mpz_add(tmp2, tmp1, acc)
  mpz_tdiv_q(tmp1, tmp2, den)
  result = mpz_get_ui(tmp1)

proc eliminate_digit(d: culong) =
   mpz_submul_ui(acc, den, d)
   mpz_mul_ui(acc, acc, 10)
   mpz_mul_ui(num, num, 10)

 
proc next_term(k: culong) =
   var k2: culong = k * 2 + 1
   mpz_addmul_ui(acc, num, 2)
   mpz_mul_ui(acc, acc, k2)
   mpz_mul_ui(den, den, k2)
   mpz_mul_ui(num, num, k)


proc writePi(ostream: Stream|File, n: int) =
  var d, k: culong
  var i: uint64
  
  mpz_init(tmp1)
  mpz_init(tmp2)
  
  mpz_init_set_ui(acc, 0)
  mpz_init_set_ui(den, 1)
  mpz_init_set_ui(num, 1)
  
  while(i < n.uint64):
    k.inc
    next_term(k)
    if mpz_cmp(num, acc) > 0:
      continue
      
    d = extract_digit(3)
    if d != extract_digit(4):
      continue
    ostream.write(chr(ord('0').uint64 + d))
    i.inc 
    #if (i mod 10'u64).uint64 == 0'u64:  echo "\t:" & $i
    eliminate_digit(d)

proc main() =
  let n = parseInt paramStr(1)
  stdout.writePi n

test "test pi digit":
  var s = newStringStream()
  const res =
    "314159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593344612847564823378678316527120190914564856692346034861045432664821339360726024914127372458700660631558817488152092096282925409171536436789259036001133053054882046652138414695194151160943305727036575959195309218611738193261179310511854807446237996274956735188575272489122793818301194912983367336244065664308602139494639522473719070217986094370277053921717629317675238467481846766940513"
  s.writePi res.len
  check s.data == res
