module Interpreter where

import AbsLambdaNat -- provides the interface with the grammar and is automatically generated by bnfc
import ErrM -- from bnfc
import PrintLambdaNat -- from bnfc
import Control.Monad.State
--import Language.Haskell.TH (Exp)

exec :: Program -> Exp
exec (Prog e) = eval e

eval :: Exp -> Exp 
eval e = evalState (eval' e) 0

eval' :: Exp -> State Int Exp
eval' (App e1 e2) = do
  e1' <- eval' e1
  case e1 of
    (Abs i e3) -> do
      e2' <- eval' e2 
      rhs <- subst i e2' e3
      eval' rhs
    e3 -> do
      e2' <- eval' e2
      return (App e3 e2')
eval' (Abs i e) = do
  e' <- eval' e
  return (Abs i e')
eval' x = return x 

fresh :: State Int Id
fresh = do
  i <- get
  put (i + 1)
  return (Id ("X" ++ show i))

-- substitute a variable id by an expression s in an expression
subst :: Id -> Exp -> Exp -> State Int Exp
subst id s (Var id1) | id == id1 = return s
                     | otherwise = return (Var id1)
subst id s (App e1 e2) = do
  e1' <- subst id s e1
  e2' <- subst id s e2
  return (App e1' e2')
subst id s (Abs id1 e1) = do
  f <- fresh
  e1' <- subst id1 (Var f) e1
  e2' <- subst id s e1'
  return (Abs f e2')

