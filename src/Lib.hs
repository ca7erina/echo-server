{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators   #-}
module Lib
    ( startApp
    ) where

import Data.Aeson
import Data.Aeson.TH
import Network.Wai
import Network.Wai.Handler.Warp
import Servant

data User = User
  { userId        :: Int
  , userFirstName :: String
  , userLastName  :: String
  } deriving (Eq, Show)

$(deriveJSON defaultOptions ''User)

newtype EchoMessage = EchoMessage { msg :: String }
  deriving (Eq, Show)

$(deriveJSON defaultOptions ''EchoMessage)


type API = "users" :> Get '[JSON] [User]
        :<|> "echo" :> QueryParam "msg" String :> Get '[JSON] EchoMessage

startApp :: IO ()
startApp = run 8080 app

app :: Application
app = serve api server

api :: Proxy API
api = Proxy

server :: Server API
server = return users
    :<|> echo

    where echo :: Maybe String -> Handler EchoMessage
          echo mname = return . EchoMessage $ case mname of
            Nothing -> "no message"
            Just n  -> "Hello, "++ n

users :: [User]
users = [ User 1 "Isaac" "Newton"
        , User 2 "Albert" "Einstein"
        ]
