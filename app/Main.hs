{-# LANGUAGE OverloadedStrings, OverloadedRecordDot, BlockArguments #-}
module Main (main) where

import Control.Monad (unless)
import Web.Scotty hiding (header)
import Options.Applicative
import Network.Wai.Middleware.Gzip
  ( GzipFiles (GzipCompress),
    GzipSettings (gzipFiles),
    def,
    gzip,
  )
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Network.Wai.Middleware.Static
  ( addBase,
    noDots,
    staticPolicy,
    (>->),
  )

data Flags = Flags
  { _optPort  :: Int
  , _optQuiet :: Bool }

flags :: Parser Flags
flags = Flags
  <$> option auto
    ( long "port" 
   <> help "Port to run on"
   <> showDefault 
   <> value 3000
   <> metavar "INT" )
  <*> switch
    ( long "quiet"
   <> short 'q'
   <> help "Don't print messages to stdout" )

main :: IO ()
main = do
  opts' <- execParser opts
  scotty (opts'._optPort) do
    -- Add policies to prevent directory traversal attacks.
    middleware $ staticPolicy (noDots >-> addBase "public")
    -- Use Gzip, which can shave seconds off load time.
    middleware $ gzip def {gzipFiles = GzipCompress}
    -- unless we are using the option -q/--quiet, log to stdout.
    unless (opts'._optQuiet) $ middleware logStdoutDev
    get "/" $ file "./public/index.html"
  where 
    opts = info (flags <**> helper)
      ( fullDesc 
     <> progDesc "Run a webserver"
     <> header   "server")
