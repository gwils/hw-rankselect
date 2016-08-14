{-# LANGUAGE FlexibleContexts   #-}
{-# LANGUAGE FlexibleInstances  #-}
{-# LANGUAGE InstanceSigs       #-}

module HaskellWorks.Data.Succinct.BalancedParens.RangeMinMax.Simple
  ( RangeMinMaxSimple(..)
  , mkRangeMinMaxSimple
  ) where

import qualified Data.Vector.Storable                                           as DVS
import           Data.Word
import           HaskellWorks.Data.Bits.BitLength
import           HaskellWorks.Data.Bits.BitWise
import           HaskellWorks.Data.Succinct.BalancedParens.Internal
import           HaskellWorks.Data.Succinct.BalancedParens.RangeMinMax.Internal
import           HaskellWorks.Data.Succinct.RankSelect.Binary.Basic.Rank0
import           HaskellWorks.Data.Succinct.RankSelect.Binary.Basic.Rank1

data RangeMinMaxSimple = RangeMinMaxSimple
  { rangeMinMaxSimpleBP     :: DVS.Vector Word64
  }

mkRangeMinMaxSimple :: DVS.Vector Word64 -> RangeMinMaxSimple
mkRangeMinMaxSimple bp = RangeMinMaxSimple
  { rangeMinMaxSimpleBP       = bp
  }

instance TestBit RangeMinMaxSimple where
  (.?.) = (.?.) . rangeMinMaxSimpleBP
  {-# INLINE (.?.) #-}

instance Rank1 RangeMinMaxSimple where
  rank1 = rank1 . rangeMinMaxSimpleBP
  {-# INLINE rank1 #-}

instance Rank0 RangeMinMaxSimple where
  rank0 = rank0 . rangeMinMaxSimpleBP
  {-# INLINE rank0 #-}

instance BitLength RangeMinMaxSimple where
  bitLength = bitLength . rangeMinMaxSimpleBP
  {-# INLINE bitLength #-}

instance RangeMinMax RangeMinMaxSimple where
  rmmFindCloseDispatch = rmmFindCloseN
  rmmFindCloseN v s p  = if v `closeAt` p
    then if s <= 1
      then Progress p
      else rmmFindClose v (s - 1) (p + 1)
    else rmmFindClose v (s + 1) (p + 1)
  {-# INLINE rmmFindCloseDispatch #-}
  {-# INLINE rmmFindCloseN        #-}

instance OpenAt RangeMinMaxSimple where
  openAt = openAt . rangeMinMaxSimpleBP
  {-# INLINE openAt #-}

instance CloseAt RangeMinMaxSimple where
  closeAt = closeAt . rangeMinMaxSimpleBP
  {-# INLINE closeAt #-}

instance BalancedParens RangeMinMaxSimple where
  -- findOpenN         = findOpenN   . rangeMinMaxBP
  findCloseN v s c = resultToMaybe (rmmFindClose v (fromIntegral s) c)

  -- {-# INLINE findOpenN   #-}
  {-# INLINE findCloseN  #-}
