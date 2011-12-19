CambiaDir=`readlink -f "$0"`
cd "`dirname "$CambiaDir"`"
Va=`cat ./.git/COMMIT_EDITMSG`
_a() 
{
a=$2
a=$(($a + 1))
b=`echo $1" ""$a"`
echo $b
rm ./roottools.sh
cp /home/tirano/tiranodev/MagicBox1/assets/roottools.sh ./
git add -A
git commit -a -m "$b"
git push -u origin master
}
_a $Va

