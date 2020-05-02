---
title: "qBittorrent WebUI如何如何批量修改tracker地址"
date: 2020-05-02T19:19:39+08:00
tags:
  - old-site
---

> 原文由 @也无荒野也无灯 发表于 2019-08-04 11:36
> 原文地址（已经不可访问): `http://nanodm.net:8092/archives/47/`

先上工具吧：
[qb-tracker-update-bulk-20190804.zip][1]
(支持 windows 64bit, Mac OSX 64bit, Linux x86_64 and arm64)

注：此下载包于2019-09-20 更新, 为了兼容之前的下载地址， 文件名保持不变，里面的内容变了.

熟悉qBittorrent 的童鞋都知道，qb可以很方便地跳过校验. 其底层的实现，依赖一个fastresume文件，每个种子都有一个对应的fastresume文件，
这里面记录着很多qb需要用到的信息，当然，也包括tracker地址.
对于已经完成的种子，qb是不会再读取torrent文件里的tracker地址的，而是直接从fastresume文件中获取.
那么，我们如果要批量修改tracker地址，是不是直接修改这些fastresume里的tracker地址就可以了？
没错，完全是可以的，但是最终荒野却没有采用这种方案，为什么？且听荒野细细道来。

libtorrent fastresume文件分析
qBittorrent 的底层bt协议实际上是用的libtorrent，就连fastresume文件，也是libtorrent中定义的.
我们先clone一份最新的1.1.13版本的代码下来（截至本文发布时间，qb 暂不支持 libtorrent 最新的1.2 rc 分支）：
git clone <https://github.com/arvidn/libtorrent.git>
git checkout libtorrent-1_1_13 -b libtorrent-1_1_13
根据其文档，我们可以知道，其保存fastresume文件是通过 save_resume_data_alert 来进行的.
<https://libtorrent.org/manual.html#save-resume-data-alert>

save_resume_data_alert 定义如下：

```cpp
https://github.com/arvidn/libtorrent/blob/libtorrent-1_1_13/include/libtorrent/alert_types.hpp#L1050

    // This alert is generated as a response to a ``torrent_handle::save_resume_data`` request.
    // It is generated once the disk IO thread is done writing the state for this torrent.
    struct TORRENT_EXPORT save_resume_data_alert TORRENT_FINAL : torrent_alert
    {
        // internal
        save_resume_data_alert(aux::stack_allocator& alloc
            , boost::shared_ptr<entry> const& rd
            , torrent_handle const& h);
        TORRENT_DEFINE_ALERT_PRIO(save_resume_data_alert, 37, alert_priority_critical)
        static const int static_category = alert::storage_notification;
        virtual std::string message() const TORRENT_OVERRIDE;
        // points to the resume data.
        boost::shared_ptr<entry> resume_data;
    };
```

然后我们看看它是怎么保存的：
<https://libtorrent.org/manual.html#save-resume-data>

从这个文档我们可以看到基本的调用过程大概如下：

```cpp
save_resume_data_alert const* rd = alert_cast<save_resume_data_alert>(a);
torrent_handle h = rd->handle;
//设置好输出流的保存路径(保存目录和文件名，根据 rd->handle 得出)
std::ofstream out((h.save_path() + "/" + h.get_torrent_info().name() + ".fastresume").c_str()
                  , std::ios_base::binary);
out.unsetf(std::ios_base::skipws);
//进行bencode编码，输出结果到out流
bencode(std::ostream_iterator<char>(out), *rd->resume_data);
```

那么，如果我们也知道这个 resume_data 的结构，是不是就能解析甚至改写这个文件呢？
从最开始我们看的 save_resume_data_alert 的文档，我们还知道了resume_data 数据类型为 boost::shared_ptr<entry>
我们看看entry的定义：
<https://libtorrent.org/manual.html#entry>

根据entry的定义，从代码并不能看出resume文件的结构。因为它实际上是程序运行时动态生成的。
于是继续看文档，GOOD, 官方文档有给出详细的解释：
<https://libtorrent.org/manual.html#fast-resume>

```
fast resume

The fast resume mechanism is a way to remember which pieces are downloaded and where they are put between sessions. You can generate fast resume data by calling save_resume_data() on torrent_handle. You can then save this data to disk and use it when resuming the torrent. libtorrent will not check the piece hashes then, and rely on the information given in the fast-resume data. The fast-resume data also contains information about which blocks, in the unfinished pieces, were downloaded, so it will not have to start from scratch on the partially downloaded pieces.

To use the fast-resume data you simply give it to async_add_torrent() add_torrent(), and it will skip the time consuming checks. It may have to do the checking anyway, if the fast-resume data is corrupt or doesn't fit the storage for that torrent, then it will not trust the fast-resume data and just do the checking.

file format

The file format is a bencoded dictionary containing the following fields:

file-format string: "libtorrent resume file"
file-version integer: 1
info-hash string, the info hash of the torrent this data is saved for.
blocks per piece integer, the number of blocks per piece. Must be: piece_size / (16 * 1024). Clamped to be within the range [1, 256]. It is the number of blocks per (normal sized) piece. Usually each block is 16 * 1024 bytes in size. But if piece size is greater than 4 megabytes, the block size will increase.
pieces A string with piece flags, one character per piece. Bit 1 means we have that piece. Bit 2 means we have verified that this piece is correct. This only applies when the torrent is in seed_mode.
slots 

list of integers. The list maps slots to piece indices. It tells which piece is on which slot. If piece index is -2 it means it is free, that there's no piece there. If it is -1, means the slot isn't allocated on disk yet. The pieces have to meet the following requirement:

If there's a slot at the position of the piece index, the piece must be located in that slot.


total_uploaded integer. The number of bytes that have been uploaded in total for this torrent.
total_downloaded integer. The number of bytes that have been downloaded in total for this torrent.
active_time integer. The number of seconds this torrent has been active. i.e. not paused.
seeding_time integer. The number of seconds this torrent has been active and seeding.
num_seeds integer. An estimate of the number of seeds on this torrent when the resume data was saved. This is scrape data or based on the peer list if scrape data is unavailable.
num_downloaders integer. An estimate of the number of downloaders on this torrent when the resume data was last saved. This is used as an initial estimate until we acquire up-to-date scrape info.
upload_rate_limit integer. In case this torrent has a per-torrent upload rate limit, this is that limit. In bytes per second.
download_rate_limit integer. The download rate limit for this torrent in case one is set, in bytes per second.
max_connections integer. The max number of peer connections this torrent may have, if a limit is set.
max_uploads integer. The max number of unchoked peers this torrent may have, if a limit is set.
seed_mode integer. 1 if the torrent is in seed mode, 0 otherwise.
file_priority list of integers. One entry per file in the torrent. Each entry is the priority of the file with the same index.
piece_priority string of bytes. Each byte is interpreted as an integer and is the priority of that piece.
auto_managed integer. 1 if the torrent is auto managed, otherwise 0.
sequential_download integer. 1 if the torrent is in sequential download mode, 0 otherwise.
paused integer. 1 if the torrent is paused, 0 otherwise.
trackers list of lists of strings. The top level list lists all tracker tiers. Each second level list is one tier of trackers.
mapped_files list of strings. If any file in the torrent has been renamed, this entry contains a list of all the filenames. In the same order as in the torrent file.
url-list list of strings. List of url-seed URLs used by this torrent. The urls are expected to be properly encoded and not contain any illegal url characters.
httpseeds list of strings. List of httpseed URLs used by this torrent. The urls are expected to be properly encoded and not contain any illegal url characters.
merkle tree string. In case this torrent is a merkle torrent, this is a string containing the entire merkle tree, all nodes, including the root and all leaves. The tree is not necessarily complete, but complete enough to be able to send any piece that we have, indicated by the have bitmask.
peers

list of dictionaries. Each dictionary has the following layout:

ip string, the ip address of the peer. This is not a binary representation of the ip address, but the string representation. It may be an IPv6 string or an IPv4 string.
port integer, the listen port of the peer

These are the local peers we were connected to when this fast-resume data was saved.

unfinished

list of dictionaries. Each dictionary represents an piece, and has the following layout:

piece integer, the index of the piece this entry refers to.
bitmask string, a binary bitmask representing the blocks that have been downloaded in this piece.
adler32 The adler32 checksum of the data in the blocks specified by bitmask.
file sizes list where each entry corresponds to a file in the file list in the metadata. Each entry has a list of two values, the first value is the size of the file in bytes, the second is the time stamp when the last time someone wrote to it. This information is used to compare with the files on disk. All the files must match exactly this information in order to consider the resume data as current. Otherwise a full re-check is issued.
allocation 
The allocation mode for the storage. Can be either full or compact. If this is full, the file sizes and timestamps are disregarded. Pieces are assumed not to have moved around even if the files have been modified after the last resume data checkpoint.
```

不过，对于qb 来说，它不是直接使用这个结构，还增加了一些自己的字段(大部分以qBt-为前缀)：
<https://github.com/qbittorrent/qBittorrent/blob/master/src/base/bittorrent/torrenthandle.cpp#L1746>

```cpp
//file src/base/bittorrent/torrenthandle.cpp
void TorrentHandle::handleSaveResumeDataAlert(const libtorrent::save_resume_data_alert *p)
{
    const bool useDummyResumeData = !(p && p->resume_data);
    libtorrent::entry dummyEntry;
    libtorrent::entry &resumeData = useDummyResumeData ? dummyEntry : *(p->resume_data);
    if (useDummyResumeData) {
        resumeData["qBt-magnetUri"] = toMagnetUri().toStdString();
        resumeData["qBt-paused"] = isPaused();
        resumeData["qBt-forced"] = isForced();
        // Both firstLastPiecePriority and sequential need to be stored in the
        // resume data if there is no metadata, otherwise they won't be
        // restored if qBittorrent quits before the metadata are retrieved:
        resumeData["qBt-firstLastPiecePriority"] = hasFirstLastPiecePriority();
        resumeData["qBt-sequential"] = isSequentialDownload();
    }
    else {
        auto savePath = resumeData.find_key("save_path")->string();
        resumeData["save_path"] = Profile::instance().toPortablePath(QString::fromStdString(savePath)).toStdString();
    }
    resumeData["qBt-savePath"] = m_useAutoTMM ? "" : Profile::instance().toPortablePath(m_savePath).toStdString();
    resumeData["qBt-ratioLimit"] = static_cast<int>(m_ratioLimit * 1000);
    resumeData["qBt-seedingTimeLimit"] = m_seedingTimeLimit;
    resumeData["qBt-category"] = m_category.toStdString();
    resumeData["qBt-tags"] = setToEntryList(m_tags);
    resumeData["qBt-name"] = m_name.toStdString();
    resumeData["qBt-seedStatus"] = m_hasSeedStatus;
    resumeData["qBt-tempPathDisabled"] = m_tempPathDisabled;
    resumeData["qBt-queuePosition"] = (nativeHandle().queue_position() + 1); // qBt starts queue at 1
    resumeData["qBt-hasRootFolder"] = m_hasRootFolder;
    m_session->handleTorrentResumeDataReady(this, resumeData);
}
```

顺便说一下：代码中的 m_useAutoTMM 的意思是，是否启用 Automatic Torrent Management
这个功能的具体解释见： <https://qbforums.shiki.hu/index.php?topic=4723.0>  和  <https://github.com/qbittorrent/qBittorrent/issues/4696>

因此，qb 的fastresume文件解码出来大概是像这样：

```
{
    "active_time": 2355814,
    "added_time": 1562421186,
    "announce_to_dht": 1,
    "announce_to_lsd": 1,
    "announce_to_trackers": 1,
    "auto_managed": 1,
    "banned_peers": "",
    "banned_peers6": "",
    "blocks per piece": 256,
    "completed_time": 1562421186,
    "download_rate_limit": -1,
    "file sizes": [
        [
            5948133398,
            1561568066
        ]
    ],
    "file-format": "libtorrent resume file",
    "file-version": 1,
    "finished_time": 2355814,
    "info-hash": "%0c%90%8d...\\",
    "last_download": -1,
    "last_scrape": 1564817494,
    "last_seen_complete": 1562685035,
    "last_upload": 1563411520,
    "libtorrent-version": "1.1.13.0",
    "max_connections": 64,
    "max_uploads": 16777215,
    "num_complete": 36,
    "num_downloaded": 16777215,
    "num_incomplete": 0,
    "paused": 0,
    "peers": "",
    "peers6": "",
    "pieces": "%01%01%01%01%01%01%01...",
    "qBt-category": "",
    "qBt-hasRootFolder": 0,
    "qBt-name": "",
    "qBt-queuePosition": 0,
    "qBt-ratioLimit": -2000,
    "qBt-savePath": "/downloads/",
    "qBt-seedStatus": 1,
    "qBt-seedingTimeLimit": -2,
    "qBt-tags": [
    ],
    "qBt-tempPathDisabled": 0,
    "save_path": "/downloads/",
    "seed_mode": 1,
    "seeding_time": 2355814,
    "sequential_download": 0,
    "super_seeding": 0,
    "total_downloaded": 0,
    "total_uploaded": 3682478255,
    "trackers": [
        [
            "https://xxxx.tr/announce.php?passkey=xxxx...."
        ]
    ],
    "upload_rate_limit": -1
}
```

我们最感兴趣的，无非是 trackers 字段了.  另外还有一个字段是 qBt-category ，这个我们可以用来实现批量修改分类（不过不能直接修改，不存在的分类，需要先添加之才能修改成它）.
既然结构已知，我们完全可以用bencode来解析这个文件，然后修改tracker地址，再回写过去。
我们先来看看bencode相关的基础知识：
由于bencode实际上是一个非常简单的编码，对于字符串来说，它会将它编码为string类型.  其格式如下：

```
<length>:<contents>
```

对于list, 其编码格式为：

```
l<contents>e
```

但是标准并没有说它能处理除了ASCII编码之外的其它编码，但是实际上现在的bt软件都支持UTF-8的字符串, 比如：
切尔诺贝利S01
将会被编码为:
18:切尔诺贝利S01
因为 “切尔诺贝利” 为UTF-8，每个中文占用3个字节，因此长度为18.
如果一个种子的文件名是中文的，可以用hexdump查看其name占用长度确认：

```
hexdump xxx.torrent -C | grep name -n2
```

想要更进一步了解的可以查看wiki: <https://en.wikipedia.org/wiki/Bencode>

这里我们只关注tracker字段，那么，对于BT种子文件，tracker的编码是：

8:announceTracker字符度长度:Tracker字符串

所以，解决办法很简单了，我们只需要用新的tracker的bencode字符串替换掉旧的就行了，在Linux下面的话，使用sed应该是很方便.
    注意:
1.这里使用了@而不是sed默认的/分隔符号，避免了与HTTP协议里的/符号冲突导致URL里的/需要转义.
2.这里使用了全URL替换，而不是局域替换.因为bencode需要知道字符串的长度，因此，我们不能简单的把tracker的局域替换完事，
因此新域名的字符串长度，可能跟旧域名不一样.
3. 我们在替换的时候，带上了前缀，避免错误替换掉不该替换的地方.
4. 域名中存在的.点号注意转义, 转义是sed BRE的要求.  sed 默认工作在BRE模式, 要了解更多可以访问：
<https://www.gnu.org/software/sed/manual/html_node/BRE-vs-ERE.html#BRE-vs-ERE>
<https://www.gnu.org/software/sed/manual/html_node/BRE-syntax.html#BRE-syntax>

对于种子文件我们可以这样替换tracker：

```
sed -i 's@8:announce42:http://tracker001\.com/announce?passkey=xxx@8:announce46:http://new.tracker007\.com/announce?passkey=ccc@g' *.torrent
sed -i 's@8:announce42:http://tracker001\.com/announce?passkey=xxx@8:announce46:http://new.tracker007\.com/announce?passkey=ccc@g'  *.torrent
```

但是fastresume文件中是这样的形式：

```
    "trackers": [
        [
            "https://xxxx.tr/announce.php?passkey=xxxx...."
        ]
    ],
```

很明显，不是key-value形式啊，这是list, 因此应该编码成：l<contents>e
但是这里有两个[]啊，因此，list里面，又是一个list. 因此编码后就像这样：

```
8:trackersll42:http://tracker001.com/announce?passkey=xxxee
```

对于fastresume文件，我们可以这样替换tracker:

```
sed -i 's@8:trackersll42:http://tracker001\.com/announce?passkey=xxxee@8:trackersll46:http://new.tracker007\.com/announce?passkey=cccee@g' *.torrent
```

同样，这里在替换的时候，带上了 8:trackersll 前缀 和 ee 后缀，避免错误替换掉不该替换的地方.

然后你会发现，还要自己计算字符串长度啊转义啊，确实有点麻烦啊，因此，网上有一个py脚本 （<https://github.com/Stat1cV01D/bt_trackers_replacer> ）其作用是替换 .fastresume 文件中的tracker地址.
虽然大部分环境下，尤其是Linux, 基本上都带有py支持，但是还是有很多没有py的环境, 因此这种方法对于我来说，依旧不太可接受。
此外，直接修改fastresume的方法有一些缺点：

1. qb关于这个fastresume文件的格式没有任何文档说明，我们不知道qb会不会在新版本中移除或增加新的字段.
2. 使这个修改生效，需要qb重新载入这些fastresume文件，因此qb本身需要重启，这会造成短暂的做种中断，对于有些PT系统的保种机制来说，可能用户不太愿意这种中断操作。

让qb自己修改fastresume
没错，既然直接修改fastresume不太好的话，我们是不是可以换个思路，间接修改fastresume

web API法， qb 有比较完善的web API接口，因此，qb的事情，我们完全可以让qb自己来处理，这样更安全也更稳妥。
web API接口 文档：<https://github.com/qbittorrent/qBittorrent/wiki/Web-API-Documentation>

很快，我们找到我们需要的获取种子列表接口：
<https://github.com/qbittorrent/qBittorrent/wiki/Web-API-Documentation#get-torrent-list>
/api/v2/torrents/info

还有编辑种子tracker的接口：
<https://github.com/qbittorrent/qBittorrent/wiki/Web-API-Documentation#edit-trackers>
/api/v2/torrents/editTracker

```
Name: editTracker

Parameters:

Parameter Type Description
hash string The hash of the torrent
origUrl string The tracker URL you want to edit
newUrl string The new URL to replace the origUrl

Returns:

HTTP Status Code Scenario

400
 newUrl is not a valid URL

404
 Torrent hash was not found

409
 newUrl already exists for the torrent

409
 origUrl was not found

200
 
All other scenarios
```

那么，逻辑已经很明了了：
先调用 get-torrent-list 返回所有种子的hash，再直接针对所有的种子调用 edit-trackers， 由于edit-trackers会判断旧tracker地址，因此不用担心会替换出错.

本着偷懒的原则，代码基本上不自己写。
在postman里面测试过这两个接口，外加一个登录接口之后，直接用postman生成代码.
取出来，把3个main方法分别改成login, torrents, editTracker 即可. 然后稍作修改，这个程序便成了。还是跨平台的，并且不需要重启qb就能即时生效.

使用也比较简单：
qb-tracker-update-bulk -a "qb webui 登录地址" -u "用户名" -p "密码" -orig  "需要替换的tracker地址" -new "新的tracker地址"

  [1]: qb-tracker-update-bulk-20190804.zip
