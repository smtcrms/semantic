module Data.Abstract.Module
( Module(..)
, ModuleInfo(..)
, ModuleName
, moduleForBlob
) where

import Data.Abstract.FreeVariables
import Data.Blob
import qualified Data.ByteString.Char8 as BC
import Data.Language
import Data.List.Split (splitWhen)
import System.FilePath.Posix

type ModuleName = Name

data ModuleInfo = ModuleInfo { moduleName :: ModuleName, modulePath :: FilePath }
  deriving (Eq, Ord, Show)

data Module term = Module { moduleInfo :: ModuleInfo, moduleBody :: term }
  deriving (Eq, Foldable, Functor, Ord, Show, Traversable)


-- | Construct a 'Module' for a 'Blob' and @term@, relative to some root 'FilePath'.
moduleForBlob :: Maybe FilePath -- ^ The root directory relative to which the module will be resolved, if any.
              -> Blob           -- ^ The 'Blob' containing the module.
              -> term           -- ^ The @term@ representing the body of the module.
              -> Module term    -- ^ A 'Module' named appropriate for the 'Blob', holding the @term@, and constructed relative to the root 'FilePath', if any.
moduleForBlob rootDir blob = Module info
  where modulePathForBlob Blob{..} | Just Go <- blobLanguage = takeDirectory (modulePath blobPath)
                                   | otherwise               =                modulePath blobPath
        -- TODO: Need a better way to handle module registration and resolution
        modulePath = dropExtensions . maybe takeFileName makeRelative rootDir
        info = ModuleInfo (moduleNameForPath (modulePathForBlob blob)) (blobPath blob)

moduleNameForPath :: FilePath -> ModuleName
moduleNameForPath = qualifiedName . map BC.pack . splitWhen (== pathSeparator)
