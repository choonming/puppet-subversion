# From http://reductivelabs.com/trac/puppet/wiki/Recipes/SubversionWorkingCopy
# Example usage: (https://reductivelabs.com/svn/vault into /var/svn/vault.cache)
#   svnworkdir { vault:
#       repository => "https://reductivelabs.com/svn/vault",
#       local_container => "/var/svn",
#       local_name => "vault.cache"
#       svn_username => "puppet",
#       svn_password => "mypassword"
#   }
#
# Note, make sure you manage file["$local_container"] somewhere else, as it's required.
# Note2, you may want to modify the require lines for your package provider for subversion

define subversion::workdir($repository, $local_container, $local_name = false, $svn_username = false, $svn_password = false, $post_checkout_script = undef, $post_update_script = undef, $runas_user = "root", $runas_group = "root")
{

    $owner_real = $owner ? { false => 0, default => $owner }
    $group_real = $group ? { false => 0, default => $group }
    $local_name_real = $local_name ? { false => $name, default => $local_name }

    Exec {
        path  => "/usr/bin:/bin:/opt/local/bin:/usr/local/bin",
        user  => $runas_user,
        group => $runas_group,
    }
    
    $retrieve_command = $svn_username ? {
        false   => "svn checkout --non-interactive '$repository' '$local_name_real'",
        default => "svn checkout --non-interactive --username='$svn_username' --password='$svn_password' '$repository' '$local_name_real'"
    }
    
    $check_command = $svn_username ? {
        false   => "svn status -u --non-interactive '$local_name_real' | grep '*'",
        default => "svn status -u --non-interactive --username='$svn_username' --password='$svn_password' '$local_name_real' | grep '*'"
    }
    
    $update_command = $svn_username ? {
        false   => "svn update --non-interactive '$local_name_real'" ,
        default => "svn update --non-interactive --username='$svn_username' --password='$svn_password' '$local_name_real'"
    }

    exec { "svn-co-$name":
        command => $retrieve_command,
        cwd     => $local_container,
        require => [ File["$local_container"], Package["subversion"]],
        creates => "$local_container/$local_name_real/.svn",
    }

    exec { "svn-up-$name":
        command => $update_command,
        cwd     => $local_container,
        require => [ Exec["svn-co-$name"], Package["subversion"]],
        onlyif  => $check_command,
    }

}
