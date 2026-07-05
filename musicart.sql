-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Jul 04, 2026 at 10:20 PM
-- Server version: 5.7.39
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `Musicart`
--

-- --------------------------------------------------------

--
-- Table structure for table `address`
--

CREATE TABLE `address` (
  `id` int(11) NOT NULL,
  `city` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `zipcode` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `street` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `address`
--

INSERT INTO `address` (`id`, `city`, `zipcode`, `street`) VALUES
(219, 'Meunier', '54987', '384, rue de Laurent'),
(220, 'Coulon', '20132', '95, rue Adèle Salmon'),
(221, 'Alexandre', '55734', 'place de Guillou'),
(222, 'Robin', '84519', '63, chemin François Pruvost'),
(223, 'Munoz', '24684', '57, rue de Techer'),
(224, 'Bouvier', '57114', '15, place Millet'),
(225, 'Deschamps-sur-Mer', '43314', '58, impasse Gabriel Andre'),
(235, 'dsqf', 'qsf', 'qsdf'),
(236, 'Lyon', '69007', '32'),
(237, 'Lyon', '69007', '52'),
(238, 'Vonnas', '01540', '43');

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`id`, `name`) VALUES
(86, 'est'),
(87, 'accusantium'),
(88, 'fuga'),
(89, 'voluptatem'),
(90, 'aut');

-- --------------------------------------------------------

--
-- Table structure for table `doctrine_migration_versions`
--

CREATE TABLE `doctrine_migration_versions` (
  `version` varchar(191) COLLATE utf8_unicode_ci NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `execution_time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `doctrine_migration_versions`
--

INSERT INTO `doctrine_migration_versions` (`version`, `executed_at`, `execution_time`) VALUES
('DoctrineMigrations\\Version20230706115947', '2023-07-27 11:36:26', 50),
('DoctrineMigrations\\Version20230706120320', '2023-07-27 11:36:26', 8),
('DoctrineMigrations\\Version20230706120531', '2023-07-27 11:36:26', 28),
('DoctrineMigrations\\Version20230706120805', '2023-07-27 11:36:26', 20),
('DoctrineMigrations\\Version20230724075614', '2023-07-27 11:36:26', 29),
('DoctrineMigrations\\Version20230724080221', '2023-07-27 11:36:26', 17),
('DoctrineMigrations\\Version20230724081524', '2023-07-27 11:36:26', 24),
('DoctrineMigrations\\Version20230727174659', '2023-07-27 17:47:58', 21),
('DoctrineMigrations\\Version20230727215308', '2023-07-27 21:54:20', 78),
('DoctrineMigrations\\Version20230728112832', '2023-07-28 11:28:56', 62),
('DoctrineMigrations\\Version20230729142117', '2023-07-29 14:21:24', 64),
('DoctrineMigrations\\Version20230810195945', '2023-08-10 20:03:55', 44),
('DoctrineMigrations\\Version20230831150635', '2023-08-31 17:06:44', 32);

-- --------------------------------------------------------

--
-- Table structure for table `nft`
--

CREATE TABLE `nft` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `img` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `launch_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `launch_price_eur` double NOT NULL,
  `launch_price_eth` double NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `nft_collection_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `nft`
--

INSERT INTO `nft` (`id`, `name`, `img`, `description`, `launch_date`, `launch_price_eur`, `launch_price_eth`, `user_id`, `nft_collection_id`) VALUES
(519, 'eos', 'https://images.unsplash.com/photo-1633119216068-12d17b878451?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NzR8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Vaubyessard elle avait rêvé la maisonnette de bambous, le nègre Domingo, le chien Fidèle, mais surtout l\'amitié douce de quelque chose: Cependant, comme les flèches d\'or d\'un trophée suspendu.', '2023-11-07 04:44:23', 1334.02, 37.522, 176, 89),
(520, 'ut', 'https://images.unsplash.com/photo-1515175192010-cf3250992719?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8ODF8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Du reste, il y en avait bien d\'autres, disait-elle, et je ne me repoussez pas! Vous êtes un misérable! s\'écria-t-elle. -- Eh quoi! dit-il, ne savez-vous pas qu\'il se trouvait confondu dans la.', '2023-02-22 16:50:23', 579.37, 18.659, 176, 88),
(522, 'non', 'https://images.unsplash.com/photo-1725127077038-3aa8c931645d?q=80&w=2787&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', 'Il y avait de côtelettes à la porte; c\'est la maison du notaire, portait un gilet de flanelle, et de pension. Elle se recueillit une minute, et, retrempant son courage au sentiment de satisfaction.', '2022-07-28 09:30:52', 979.41, 53.468, 177, 86),
(523, 'porro', 'https://images.unsplash.com/photo-1508973379184-7517410fb0bc?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cmFwfGVufDB8fDB8fHww', 'Ensuite, elle examinait l\'appartement, elle ouvrait sa fenêtre, par l\'impatience où elle montait sur l\'estrade une petite vieille femme de chambre. -- De quel monde êtes-vous? dit la petite Bovary.', '2022-08-27 05:25:12', 3792.13, 69.967, 175, 90),
(524, 'a', 'https://plus.unsplash.com/premium_photo-1661715168108-026d440c1661?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cmFwfGVufDB8fDB8fHww', 'Pour s\'être découvert trois cheveux gris sur les carreaux comme des balles d\'or rebondissantes. Quel bonheur dans ce coeur d\'adolescent ouvert aux émanations de sa bouche. --Ah! mon Dieu! un article.', '2024-03-16 21:00:14', 4535, 52.987, 177, 88),
(529, 'amet', 'https://images.unsplash.com/photo-1486693242893-5ef70e1ff6e8?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Pourquoi ces emportements? Il expliquait tout par son nom gravé sur la tête, regardant autour d\'elle, en claquant de la charrette à un homme de science ne peut s\'embarrasser aux détails pratiques de.', '2023-07-29 22:38:32', 2756.02, 93.804, 176, 87),
(531, 'sint', 'https://images.unsplash.com/photo-1584679109594-56fffe50d527?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Un quart d\'heure pour les autres. Il demandait: -- Quels autres? -- Mais je ne sais pas! c\'est pour cela suer ferme sur l\'aviron, et acquérir, comme on eût fait à Paris! Et cette parole, comme un.', '2023-11-04 07:30:51', 2661.36, 78.424, 177, 88),
(534, 'error', 'https://images.unsplash.com/photo-1629753863735-4c9ba15bc10b?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Il se tenait en face, comme son successeur. Mais ce sont les traces de leurs pas dans l\'escalier: c\'était Léon. Elle eût bien voulu, ne fût-ce au moins quinze mille livres de rente. Quoiqu\'elle fût.', '2022-09-09 11:32:00', 8838.01, 58.515, 175, 86),
(536, 'unde', 'https://images.unsplash.com/photo-1718434156565-e18a83ea2869?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Café Français, que M. Lheureux lui avait fallu continuer la route. M. Homais ne trouvait pas. Mais les leçons étaient si complètement perdus en la baisant encore et pleurant sur les branches des.', '2023-11-15 21:23:34', 6912.21, 59.417, 177, 88),
(537, 'eius', 'https://images.unsplash.com/photo-1668749091738-6b328bc6e758?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjd8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Oh! je m\'imagine... -- Eh! comment veux-tu que je ne suis pas de soucis, nul obstacle! Nous serons seuls, tout à fait. Elle abandonna la musique. Elle se mettait à genoux vers elle, elle levait vers.', '2024-03-18 06:33:15', 6420.85, 60.116, 176, 87),
(539, 'maiores', 'https://images.unsplash.com/photo-1600660777574-1eb2ac6d8e43?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzB8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Certainement! continuait Homais, il y eut des étouffements aux premières chaleurs, quand les autres instruments se taisaient; on entendait toujours le souvenir de sa mère, elle porterait comme elle.', '2023-04-11 14:09:54', 8767.02, 99.402, 177, 89),
(540, 'aut', 'https://images.unsplash.com/photo-1668749095111-edffdf84a034?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzJ8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Charles ne pouvait maintenant s\'y remettre, pour des aspirations vers l\'amant, les brûlures de la Chine inaugurant l\'année par des boudins qui avaient apporté, les meubles de sa pupille à travers.', '2024-03-10 00:53:56', 3198.05, 21.505, 176, 88),
(541, 'enim', 'https://images.unsplash.com/photo-1505964253539-4ca5a36328dd?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDd8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'La pluie venait les interrompre, ou une cahute de cantonnier; quelquefois même, afin de contempler une dernière fois cette chevelure entière qui descendait lentement la côte des Leux, en traînant.', '2023-12-03 07:14:56', 1513.56, 22.584, 177, 90),
(544, 'nobis', 'https://images.unsplash.com/photo-1703420371037-7b82b9de4493?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTV8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Elle la prit dès le vendredi suivant, Charles, en voyant le faux anneau de fiançailles qui doit finir par friser l\'hérésie et même il tremblait déjà, dans la douceur de cette sensation surchargeait.', '2024-01-14 14:36:34', 2101.22, 90.329, 176, 89),
(545, 'saepe', 'https://images.unsplash.com/photo-1668352851504-0c5d240bbe70?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTR8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Ce qui l\'effrayait le plus, c\'était l\'abattement d\'Emma; car elle sortait quelquefois, afin d\'être seule un instant et de choses, y retrouvant pêle-mêle des bouquets, une jarretière, un masque noir.', '2023-05-01 14:37:02', 3922.02, 12.99, 176, 89),
(546, 'non', 'https://images.unsplash.com/photo-1600394970797-6a1099170716?q=80&w=2624&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', 'Elle le savourait sans remords, sans inquiétude, lorsqu\'un soir, tout à coup, comme à Rouen voir son amant. Mais, en écrivant, elle percevait un autre amour au-dessus de sa besogne. Ce n\'étaient.', '2024-01-26 14:09:02', 8375.68, 44.703, 177, 86),
(548, 'perspiciatis', 'https://images.unsplash.com/photo-1620281408936-b34691bbb34a?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NjN8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Elle était si surchargé, que l\'on empêcherait Emma de sa pharmacie, racontait en quelle décadence elle était emportée depuis huit jours vers un pays nouveau, d\'où ils ne bougeaient pas plus que.', '2022-05-26 06:28:30', 5628.17, 86.718, 177, 90),
(549, 'test', 'https://images.unsplash.com/photo-1600394984943-3d6c3ed9ab04?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8ODJ8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'test', '2024-04-24 14:01:24', 2, 2, 178, 87),
(550, 'NFT 3', 'https://images.unsplash.com/photo-1621608559536-0846fd224dc2?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OTN8fHJhcHxlbnwwfHwwfHx8MA%3D%3D', 'Description', '2024-09-03 09:45:42', 2030, 1, 178, 88),
(552, 'NFT', 'https://etudestech.com/wp-content/uploads/2023/05/midjourney-scaled.jpeg', 'descsds', '2024-09-27 14:20:14', 1, 4, 190, 87),
(553, 'mon ptit nft', 'C:\\fakepath\\images.jpeg', 'descriptiiion', '2026-07-01 22:00:00', 3, 5, 191, 88);

-- --------------------------------------------------------

--
-- Table structure for table `nftcollection`
--

CREATE TABLE `nftcollection` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `nftcollection`
--

INSERT INTO `nftcollection` (`id`, `name`, `description`) VALUES
(86, 'ut', 'Et ut consequatur aliquam blanditiis sed in totam. Et qui voluptas hic corrupti et placeat qui. Laborum nesciunt numquam molestias neque velit aut aut omnis. Tempore eligendi nobis occaecati et delectus rerum.'),
(87, 'necessitatibus', 'Consequatur commodi corrupti nam rem cupiditate optio. Qui nihil nesciunt cupiditate ut. Rerum excepturi praesentium aut aut animi. Optio nulla magnam repudiandae est provident et.'),
(88, 'aut', 'Sit suscipit ad et fugiat accusantium reprehenderit. Repellendus doloremque laudantium voluptatem perspiciatis esse officia eaque. Nemo et temporibus inventore eum placeat labore quod.'),
(89, 'et', 'Eum rem repudiandae ut odio pariatur. Dolores placeat voluptatem accusantium et fugiat aut minima. Maiores quasi eligendi incidunt in ut dolores est. Accusamus veniam facilis alias enim aut autem corrupti.'),
(90, 'ut', 'Quo iste a sunt doloremque non vel vero ratione. Et cumque sed sit. Vitae assumenda nihil ut molestiae exercitationem eveniet aut maiores. Sit possimus maxime aut culpa. Reiciendis magni facilis et nihil. Omnis odio qui error.');

-- --------------------------------------------------------

--
-- Table structure for table `nft_category`
--

CREATE TABLE `nft_category` (
  `nft_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `nft_category`
--

INSERT INTO `nft_category` (`nft_id`, `category_id`) VALUES
(519, 89),
(520, 90),
(522, 88),
(523, 87),
(524, 86),
(529, 89),
(531, 88),
(534, 88),
(536, 90),
(537, 88),
(539, 90),
(540, 86),
(541, 89),
(544, 89),
(545, 89),
(546, 88),
(548, 86);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `address_id` int(11) DEFAULT NULL,
  `pseudo` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roles` longtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '(DC2Type:json)',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` tinyint(1) NOT NULL,
  `firstname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `birth_date` date NOT NULL,
  `profil_picture` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `address_id`, `pseudo`, `roles`, `password`, `email`, `gender`, `firstname`, `lastname`, `birth_date`, `profil_picture`) VALUES
(175, 219, 'zbruneau', '[\"ROLE_USER\"]', '$2y$13$o0lJ8GLHs2Ky4l697moe/ezPRTG8akC6hlXbYyrpv6kyFAXkCZASW', 'vpayet@hotmail.fr', 1, 'Margot', 'Millet', '1974-01-31', '../../../assets/photo-de-profil.png'),
(176, 220, 'victoire.weber', '[\"ROLE_USER\"]', '$2y$13$pvhmvu7gYBUm.L7LOD1VUerkz2Q7pG2Ml5eSRyBPgnCko1SCS2K6m', 'yfernandes@orange.fr', 1, 'Lucy', 'Lopes', '1997-10-25', '../../../assets/photo-de-profil.png'),
(177, 221, 'luc.durand', '[\"ROLE_USER\"]', '$2y$13$zLMQJ91930Z2LkAsTzSeI.7ieYNlQiyhIlvkxl/uq.be5JyqjuolK', 'julie.rolland@wanadoo.fr', 0, 'Anastasie', 'Camus', '1967-11-18', '../../../assets/photo-de-profil.png'),
(178, 222, 'admin', '[\"ROLE_ADMIN\"]', 'admin', 'admin@admin.com', 1, 'Nathalie', 'Tanguy', '1979-07-21', '../../../assets/photo-de-profil.png'),
(179, 226, 'Theyozz', '[\"ROLE_USER\"]', '$2y$13$HAAYMLyj0a4ipEio3KBufO4zRcUxomOB//n5SmKYjRScJRT8BfAry', 'theomaurin875@gmail.com', 1, 'Theo', 'MAURIN', '2000-06-23', '../../../assets/photo-de-profil.png'),
(190, 237, 'doranco', '[\"ROLE_USER\"]', '$2y$13$ReIp1DnsQgCGbwouiLeINOJxk090PkimF6Yz9PcDILohjQmoMuAHS', 'doranco@gmail.com', 1, 'Doranco', 'Doranco', '2024-09-13', '../../../assets/photo-de-profil.png'),
(191, 238, 'theyozzzz', '[\"ROLE_USER\"]', '$2y$13$n/InlTyT8HU22Aakz8Zu/OZ8IHscCrx/KOb2i3jFhZ.xsScxTdf/e', 'theomaurisqdn875@gmail.com', 1, 'theo', 'vieilledentmaurin', '2026-07-16', '../../../assets/photo-de-profil.png');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `address`
--
ALTER TABLE `address`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `doctrine_migration_versions`
--
ALTER TABLE `doctrine_migration_versions`
  ADD PRIMARY KEY (`version`);

--
-- Indexes for table `nft`
--
ALTER TABLE `nft`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_D9C7463CA76ED395` (`user_id`),
  ADD KEY `IDX_D9C7463C327C6A9D` (`nft_collection_id`);

--
-- Indexes for table `nftcollection`
--
ALTER TABLE `nftcollection`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `nft_category`
--
ALTER TABLE `nft_category`
  ADD PRIMARY KEY (`nft_id`,`category_id`),
  ADD KEY `IDX_33F048EFE813668D` (`nft_id`),
  ADD KEY `IDX_33F048EF12469DE2` (`category_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_8D93D64986CC499D` (`pseudo`),
  ADD UNIQUE KEY `UNIQ_8D93D649F5B7AF75` (`address_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `address`
--
ALTER TABLE `address`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=239;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- AUTO_INCREMENT for table `nft`
--
ALTER TABLE `nft`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=554;

--
-- AUTO_INCREMENT for table `nftcollection`
--
ALTER TABLE `nftcollection`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=192;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `nft`
--
ALTER TABLE `nft`
  ADD CONSTRAINT `FK_D9C7463C327C6A9D` FOREIGN KEY (`nft_collection_id`) REFERENCES `nftcollection` (`id`),
  ADD CONSTRAINT `nft_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `nft_category`
--
ALTER TABLE `nft_category`
  ADD CONSTRAINT `FK_33F048EF12469DE2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_33F048EFE813668D` FOREIGN KEY (`nft_id`) REFERENCES `nft` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `FK_8D93D649F5B7AF75` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
