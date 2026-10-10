target triple = "riscv64-unknown-linux-gnu"

declare signext i32 @getint()
declare void @putint(i32 signext)
declare void @putch(i32 signext)

define signext i32 @fact(i32 signext %n) {
entry:
  br label %loop

loop:
  %i = phi i32 [ 2, %entry ], [ %i.next, %body ]
  %result = phi i32 [ 1, %entry ], [ %result.next, %body ]
  %cond = icmp sle i32 %i, %n
  br i1 %cond, label %body, label %exit

body:
  %result.next = mul nsw i32 %result, %i
  %i.next = add nsw i32 %i, 1
  br label %loop

exit:
  ret i32 %result
}

define signext i32 @main() {
entry:
  %n = call signext i32 @getint()
  %result = call signext i32 @fact(i32 signext %n)
  call void @putint(i32 signext %result)
  call void @putch(i32 signext 10)
  ret i32 0
}