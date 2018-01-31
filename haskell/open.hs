#!/usr/bin/env stack
-- stack --install-ghc runghc --package turtle

{-# LANGUAGE OverloadedStrings #-}

module Main where

import Turtle hiding (f, x)
import Data.Text (intercalate)

onHead :: (Monad m) => (a -> m a) -> [a] -> m [a]
onHead _ [] = return []
onHead f (x:xs) = (flip (:) xs) <$> f x

inshell' :: Text -> Shell Line -> Shell Text
inshell' c i = lineToText <$> inshell c i

main :: IO ()
main = sh $ do
  as <- arguments >>= onHead (\x -> inshell' ("cygpath -w \"" <> x <> "\"") empty)
  shell ("cmd /C start \"\" \"" <> intercalate " " as <> "\" >nul 2>&1") empty
