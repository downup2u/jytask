//
//  cppwrap.h
//  cpphonemodule
//
//  Created by wxqdev on 14-11-18.
//
//

#ifndef cpphonemodule_cppwrap_h
#define cpphonemodule_cppwrap_h

#include <string>
std::string initDB(const std::string&sPath);
std::string getMessage(const std::string&sPath);
std::string getTaskDetailHtml(const std::string&sIn1,const std::string&sIn2);
#endif
