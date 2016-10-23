{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ScopedTypeVariables        #-}

module HaskellWorks.Data.RankSelect.Poppy512Spec (spec) where

import           GHC.Exts
import           Data.Maybe
import qualified Data.Vector.Storable                                       as DVS
import           Data.Word
import           HaskellWorks.Data.AtIndex
import           HaskellWorks.Data.Bits.BitRead
import           HaskellWorks.Data.Bits.BitShow
import           HaskellWorks.Data.Bits.PopCount.PopCount0
import           HaskellWorks.Data.Bits.PopCount.PopCount1
import           HaskellWorks.Data.RankSelect.Base.Rank0
import           HaskellWorks.Data.RankSelect.Base.Rank1
import           HaskellWorks.Data.RankSelect.Base.Select0
import           HaskellWorks.Data.RankSelect.Base.Select1
import           HaskellWorks.Data.RankSelect.BasicGen
import           HaskellWorks.Data.RankSelect.Poppy512
import           Prelude hiding (length)
import           Test.Hspec
import           Test.QuickCheck

{-# ANN module ("HLint: ignore Redundant do" :: String) #-}
{-# ANN module ("HLint: ignore Reduce duplication"  :: String) #-}

newtype ShowVector a = ShowVector a deriving (Eq, BitShow)

instance BitShow a => Show (ShowVector a) where
  show = bitShow

vectorSizedBetween :: Int -> Int -> Gen (ShowVector (DVS.Vector Word64))
vectorSizedBetween a b = do
  n   <- choose (a, b)
  xs  <- sequence [ arbitrary | _ <- [1 .. n] ]
  return $ ShowVector (fromList xs)

spec :: Spec
spec = describe "HaskellWorks.Data.RankSelect.Poppy512.Rank1Spec" $ do
  genRankSelectSpec (undefined :: Poppy512)
  describe "rank1 for Vector Word64 is equivalent to rank1 for Poppy512" $ do
    it "on empty bitvector" $
      let v = DVS.empty in
      let w = makePoppy512 v in
      let i = 0 in
      rank1 v i === rank1 w i
    it "on one basic block" $
      forAll (vectorSizedBetween 1 8) $ \(ShowVector v) ->
      forAll (choose (0, length v * 8)) $ \i ->
      let w = makePoppy512 v in
      rank1 v i === rank1 w i
    it "on two basic blocks" $
      forAll (vectorSizedBetween 9 16) $ \(ShowVector v) ->
      forAll (choose (0, length v * 8)) $ \i ->
      let w = makePoppy512 v in
      rank1 v i === rank1 w i
    it "on three basic blocks" $
      forAll (vectorSizedBetween 17 24) $ \(ShowVector v) ->
      forAll (choose (0, length v * 8)) $ \i ->
      let w = makePoppy512 v in
      rank1 v i === rank1 w i
  describe "rank0 for Vector Word64 is equivalent to rank0 for Poppy512" $ do
    it "on empty bitvector" $
      let v = DVS.empty in
      let w = makePoppy512 v in
      let i = 0 in
      rank0 v i === rank0 w i
    it "on one basic block" $
      forAll (vectorSizedBetween 1 8) $ \(ShowVector v) ->
      forAll (choose (0, length v * 8)) $ \i ->
      let w = makePoppy512 v in
      rank0 v i === rank0 w i
    it "on two basic blocks" $
      forAll (vectorSizedBetween 9 16) $ \(ShowVector v) ->
      forAll (choose (0, length v * 8)) $ \i ->
      let w = makePoppy512 v in
      rank0 v i === rank0 w i
    it "on three basic blocks" $
      forAll (vectorSizedBetween 17 24) $ \(ShowVector v) ->
      forAll (choose (0, length v * 8)) $ \i ->
      let w = makePoppy512 v in
      rank0 v i === rank0 w i
  describe "select0 for Vector Word64 is equivalent to select0 for Poppy512" $ do
    it "on empty bitvector" $
      let v = DVS.empty in
      let w = makePoppy512 v in
      let i = 0 in
      select0 v i === select0 w i
    it "on one full zero basic block" $
      let v = fromList [0, 0, 0, 0, 0, 0, 0, 0] :: DVS.Vector Word64 in
      let w = makePoppy512 v in
      select0 v 0 === select0 w 0
    it "on one basic block" $
      forAll (vectorSizedBetween 1 8) $ \(ShowVector v) ->
      forAll (choose (0, popCount0 v)) $ \i ->
      let w = makePoppy512 v in
      select0 v i === select0 w i
    it "on two basic blocks" $
      forAll (vectorSizedBetween 9 16) $ \(ShowVector v) ->
      forAll (choose (0, popCount0 v)) $ \i ->
      let w = makePoppy512 v in
      select0 v i === select0 w i
    it "on three basic blocks" $
      forAll (vectorSizedBetween 17 24) $ \(ShowVector v) ->
      forAll (choose (0, popCount0 v)) $ \i ->
      let w = makePoppy512 v in
      select0 v i === select0 w i
  describe "select1 for Vector Word64 is equivalent to select1 for Poppy512" $ do
    it "on empty bitvector" $
      let v = DVS.empty in
      let w = makePoppy512 v in
      let i = 0 in
      select1 v i === select1 w i
    it "on one full zero basic block" $
      let v = fromList [0, 0, 0, 0, 0, 0, 0, 0] :: DVS.Vector Word64 in
      let w = makePoppy512 v in
      select1 v 0 === select1 w 0
    it "on one basic block" $
      forAll (vectorSizedBetween 1 8) $ \(ShowVector v) ->
      forAll (choose (0, popCount1 v)) $ \i ->
      let w = makePoppy512 v in
      select1 v i === select1 w i
    it "on two basic blocks" $
      forAll (vectorSizedBetween 9 16) $ \(ShowVector v) ->
      forAll (choose (0, popCount1 v)) $ \i ->
      let w = makePoppy512 v in
      select1 v i === select1 w i
    it "on three basic blocks" $
      forAll (vectorSizedBetween 17 24) $ \(ShowVector v) ->
      forAll (choose (0, popCount1 v)) $ \i ->
      let w = makePoppy512 v in
      select1 v i === select1 w i
  describe "Rank select over large buffer" $ do
    it "Rank works" $ do
      let cs = fromJust (bitRead (take 4096 (cycle "10"))) :: DVS.Vector Word64
      let ps = makePoppy512 cs
      (rank1 ps `map` [1 .. 4096]) `shouldBe` [(x - 1) `div` 2 + 1 | x <- [1 .. 4096]]
    it "Select works" $ do
      let cs = fromJust (bitRead (take 4096 (cycle "10"))) :: DVS.Vector Word64
      let ps = makePoppy512 cs
      (select1 ps `map` [1 .. 2048]) `shouldBe` [1, 3 .. 4096]