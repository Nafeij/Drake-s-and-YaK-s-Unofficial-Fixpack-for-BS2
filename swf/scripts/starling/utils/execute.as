package starling.utils
{
   public function execute(param1:Function, ... rest) : void
   {
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      if(param1 != null)
      {
         _loc4_ = param1.length;
         _loc3_ = int(rest.length);
         while(_loc3_ < _loc4_)
         {
            rest[_loc3_] = null;
            _loc3_++;
         }
         switch(_loc4_)
         {
            case 0:
               param1();
               break;
            case 1:
               param1(rest[0]);
               break;
            case 2:
               param1(rest[0],rest[1]);
               break;
            case 3:
               param1(rest[0],rest[1],rest[2]);
               break;
            case 4:
               param1(rest[0],rest[1],rest[2],rest[3]);
               break;
            case 5:
               param1(rest[0],rest[1],rest[2],rest[3],rest[4]);
               break;
            case 6:
               param1(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
               break;
            case 7:
               param1(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
               break;
            default:
               param1.apply(null,rest.slice(0,_loc4_));
         }
      }
   }
}
