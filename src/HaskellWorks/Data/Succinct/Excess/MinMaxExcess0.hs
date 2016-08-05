{-# LANGUAGE FlexibleInstances          #-}

module HaskellWorks.Data.Succinct.Excess.MinMaxExcess0
  ( MinMaxExcess0(..)
  , MaxExcess
  , MinExcess
  ) where

import qualified Data.Vector.Storable                 as DVS
import           Data.Word
import           HaskellWorks.Data.Bits.BitWise
import           HaskellWorks.Data.Bits.FixedBitSize

type MinExcess = Int
type MaxExcess = Int
type Excess    = Int

class MinMaxExcess0 a where
  minMaxExcess0 :: a -> (MinExcess, Excess, MaxExcess)

instance MinMaxExcess0 [Bool] where
  minMaxExcess0 = go 0 0 0
    where go minE maxE e (x:xs)                   = let ne = if x then e + 1 else e - 1 in
                                                        go (minE `min` ne) (maxE `max` ne) ne xs
          go minE maxE e _                        = (minE, e, maxE)

instance MinMaxExcess0 Word8 where
  minMaxExcess0 = go 0 0 0 0
    where go minE maxE e n w | n < fixedBitSize w = let ne = if w .?. fromIntegral n then e + 1 else e - 1 in
                                                        go (minE `min` ne) (maxE `max` ne) ne (n + 1) w
          go minE maxE e _ _                       = (minE, e, maxE)

instance MinMaxExcess0 Word16 where
  minMaxExcess0 = go 0 0 0 0
    where go minE maxE e n w | n < fixedBitSize w = let ne = if w .?. fromIntegral n then e + 1 else e - 1 in
                                                        go (minE `min` ne) (maxE `max` ne) ne (n + 1) w
          go minE maxE e _ _                      = (minE, e, maxE)

instance MinMaxExcess0 Word32 where
  minMaxExcess0 = go 0 0 0 0
    where go minE maxE e n w | n < fixedBitSize w = let ne = if w .?. fromIntegral n then e + 1 else e - 1 in
                                                        go (minE `min` ne) (maxE `max` ne) ne (n + 1) w
          go minE maxE e _ _                      = (minE, e, maxE)

instance MinMaxExcess0 Word64 where
  minMaxExcess0 = go 0 0 0 0
    where go minE maxE e n w | n < fixedBitSize w = let ne = if w .?. fromIntegral n then e + 1 else e - 1 in
                                                        go (minE `min` ne) (maxE `max` ne) ne (n + 1) w
          go minE maxE e _ _                      = (minE, e, maxE)

instance MinMaxExcess0 (DVS.Vector Word8) where
  minMaxExcess0 = DVS.foldl gen (0, 0, 0)
    where gen :: (MinExcess, Excess, MaxExcess) -> Word8 -> (MinExcess, Excess, MaxExcess)
          gen (minE, e, maxE) w = let (wMinE, wE, wMaxE) = minMaxExcess0 w  in
                                  (minE `min` (wMinE + e), e + wE, maxE `max` (wMaxE + e))

instance MinMaxExcess0 (DVS.Vector Word16) where
  minMaxExcess0 = DVS.foldl gen (0, 0, 0)
    where gen :: (MinExcess, Excess, MaxExcess) -> Word16 -> (MinExcess, Excess, MaxExcess)
          gen (minE, e, maxE) w = let (wMinE, wE, wMaxE) = minMaxExcess0 w  in
                                  (minE `min` (wMinE + e), e + wE, maxE `max` (wMaxE + e))

instance MinMaxExcess0 (DVS.Vector Word32) where
  minMaxExcess0 = DVS.foldl gen (0, 0, 0)
    where gen :: (MinExcess, Excess, MaxExcess) -> Word32 -> (MinExcess, Excess, MaxExcess)
          gen (minE, e, maxE) w = let (wMinE, wE, wMaxE) = minMaxExcess0 w  in
                                  (minE `min` (wMinE + e), e + wE, maxE `max` (wMaxE + e))

instance MinMaxExcess0 (DVS.Vector Word64) where
  minMaxExcess0 = DVS.foldl gen (0, 0, 0)
    where gen :: (MinExcess, Excess, MaxExcess) -> Word64 -> (MinExcess, Excess, MaxExcess)
          gen (minE, e, maxE) w = let (wMinE, wE, wMaxE) = minMaxExcess0 w  in
                                  (minE `min` (wMinE + e), e + wE, maxE `max` (wMaxE + e))