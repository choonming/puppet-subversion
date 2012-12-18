# Example usage: 
#   subversion::create { "/var/lib/svn/blah":
#       user  => "www-data",    
#       group => "www-data",    
#   }
define subversion::create($user = false, $group = false)
{

    $user_real  = $user ? { false => 0, default => $user }
    $group_real = $group ? { false => 0, default => $group }

    Exec {
        path  => "/usr/bin:/bin:/opt/local/bin:/usr/local/bin",
    }

    exec { "svnadmin-create-$name":
        command     => "/usr/bin/svnadmin create $name",
        creates     => "$name/db",
        user        => $user_real,
        group       => $group_real,
        environment => "HOME=''", # overcomes a stupid bug where svnadmin wants to read /root/.subversion
    }

}
