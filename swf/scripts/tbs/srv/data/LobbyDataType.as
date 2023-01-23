package tbs.srv.data
{
   import engine.core.util.Enum;
   
   public class LobbyDataType extends Enum
   {
      
      public static const INVITE:LobbyDataType = new LobbyDataType("INVITE",enumCtorKey);
      
      public static const UNINVITE:LobbyDataType = new LobbyDataType("UNINVITE",enumCtorKey);
      
      public static const JOIN:LobbyDataType = new LobbyDataType("JOIN",enumCtorKey);
      
      public static const DECLINE:LobbyDataType = new LobbyDataType("DECLINE",enumCtorKey);
      
      public static const EXIT:LobbyDataType = new LobbyDataType("EXIT",enumCtorKey);
      
      public static const READY:LobbyDataType = new LobbyDataType("READY",enumCtorKey);
      
      public static const UNREADY:LobbyDataType = new LobbyDataType("UNREADY",enumCtorKey);
      
      public static const OPTIONS:LobbyDataType = new LobbyDataType("OPTIONS",enumCtorKey);
      
      public static const PARTY:LobbyDataType = new LobbyDataType("PARTY",enumCtorKey);
      
      public static const VARIATION:LobbyDataType = new LobbyDataType("VARIATION",enumCtorKey);
      
      public static const TERMINATED:LobbyDataType = new LobbyDataType("TERMINATED",enumCtorKey);
       
      
      public function LobbyDataType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
