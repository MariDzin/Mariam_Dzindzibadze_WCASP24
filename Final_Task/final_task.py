"""
Module for preparing inverted indexes based on uploaded documents
"""
import json
import re
import sys
from argparse import ArgumentParser, ArgumentTypeError, FileType
from io import TextIOWrapper
from typing import Dict, List

DEFAULT_PATH_TO_STORE_INVERTED_INDEX = "inverted.index"
DEFAULT_PATH_TO_STORE_STOP_WORDS = "stop_words_en.txt"


class EncodedFileType(FileType):
    """File encoder"""

    def __call__(self, string):
        # the special argument "-" means sys.std{in,out}
        if string == "-":
            if "r" in self._mode:
                stdin = TextIOWrapper(sys.stdin.buffer, encoding=self._encoding)
                return stdin
            if "w" in self._mode:
                stdout = TextIOWrapper(sys.stdout.buffer, encoding=self._encoding)
                return stdout
            msg = 'argument "-" with mode %r' % self._mode
            raise ValueError(msg)

        # all other arguments are used as file names
        try:
            return open(string, self._mode, self._bufsize, self._encoding, self._errors)
        except OSError as exception:
            args = {"filename": string, "error": exception}
            message = "can't open '%(filename)s': %(error)s"
            raise ArgumentTypeError(message % args)

    def print_encoder(self):
        """printer of encoder"""
        print(self._encoding)


class InvertedIndex:
    """
    This module is necessary to extract inverted indexes from documents.
    """

    def __init__(self, words_ids: Dict[str, List[int]]):
        self.words_ids = words_ids

    def query(self, words: List[str]) -> List[int]:
        """Return the list of relevant documents for the given query"""
        result = set()
        for word in words:
            if word in self.words_ids:
                if not result:
                    result = set(self.words_ids[word])
                else:
                    result &= set(self.words_ids[word])
            else:
                return []
        return list(result)

    def dump(self, filepath: str) -> None:
        """
        Allow us to write inverted indexes documents to temporary directory or local storage
        :param filepath: path to file with documents
        :return: None
        """
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(self.words_ids, f)

    @classmethod
    def load(cls, filepath: str):
        """
        Allow us to upload inverted indexes from either temporary directory or local storage
        :param filepath: path to file with documents
        :return: InvertedIndex
        """
        with open(filepath, 'r', encoding='utf-8') as f:
            words_ids = json.load(f)
        return cls(words_ids)


def load_documents(filepath: str) -> Dict[int, str]:
    """
    Allow us to upload documents from either tempopary directory or local storage
    :param filepath: path to file with documents
    :return: Dict[int, str]
    """
    documents = {}
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            for index, line in enumerate(file):
                documents[index] = line.strip()
    except FileNotFoundError:
        print(f"Error: The file at {filepath} was not found.")
    except IOError:
        print(f"Error: An IOError occurred while reading the file at {filepath}.")

    return documents


def load_stop_words(filepath: str) -> List[str]:
    """
    Allow us to upload stop words
    :param filepath: path to file with stop words
    :return: List[str]
    """
    stop_words = []
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            for line in file:
                stop_words.append(line.strip())
    except FileNotFoundError:
        print(f"Error: The file at {filepath} was not found.")
    except IOError:
        print(f"Error: An IOError occurred while reading the file at {filepath}.")

    return stop_words


def build_inverted_index(documents: Dict[int, str], stop_words: List[str]) -> InvertedIndex:
    """
    Builder of inverted indexes based on documents
    :param documents: dict with documents
    :param stop_words: List of stopping words
    :return: InvertedIndex class
    """
    words_ids = {}
    for doc_id, content in documents.items():
        words = re.split(r'\W+', content.lower())
        for word in words:
            if word:
                if word in stop_words:
                    continue
                if word not in words_ids:
                    words_ids[word] = []
                if doc_id not in words_ids[word]:
                    words_ids[word].append(doc_id)
    return InvertedIndex(words_ids)


def callback_build(arguments) -> None:
    """process build runner"""
    return process_build(arguments.dataset, arguments.output)


def process_build(dataset, output) -> None:
    """
    Function is responsible for running of a pipeline to load documents,
    build and save inverted index.
    :return: None
    """
    documents: Dict[int, str] = load_documents(dataset)
    stop_words: List[str] = load_stop_words(DEFAULT_PATH_TO_STORE_STOP_WORDS)
    inverted_index = build_inverted_index(documents, stop_words)
    inverted_index.dump(output)


def callback_query(arguments) -> None:
    """ "callback query runner"""
    process_query(arguments.query, arguments.index)


def process_query(queries, index) -> None:
    """
    Function is responsible for loading inverted indexes
    and printing document indexes for keywords from arguments. Query
    :return: None
    """
    inverted_index = InvertedIndex.load(index)
    for query in queries:
        print(query[0])
        if isinstance(query, str):
            query = query.strip().split()

        doc_indexes = ",".join(str(value) for value in inverted_index.query(query))
        print(doc_indexes)


def setup_subparsers(parser) -> None:
    """
    Initial subparsers with arguments.
    :param parser: Instance of ArgumentParser
    """
    subparser = parser.add_subparsers(dest="command")
    build_parser = subparser.add_parser(
        "build",
        help="this parser is need to load, build"
             " and save inverted index bases on documents",
    )
    build_parser.add_argument(
        "-d",
        "--dataset",
        required=True,
        help="You should specify path to file with documents. ",
    )
    build_parser.add_argument(
        "-o",
        "--output",
        default=DEFAULT_PATH_TO_STORE_INVERTED_INDEX,
        help="You should specify path to save inverted index. "
             "The default: %(default)s",
    )
    build_parser.set_defaults(callback=callback_build)

    query_parser = subparser.add_parser(
        "query", help="This parser is need to load and apply inverted index"
    )
    query_parser.add_argument(
        "--index",
        default=DEFAULT_PATH_TO_STORE_INVERTED_INDEX,
        help="specify the path where inverted indexes are. " "The default: %(default)s",
    )
    query_file_group = query_parser.add_mutually_exclusive_group(required=True)
    query_file_group.add_argument(
        "-q",
        "--query",
        dest="query",
        action="append",
        nargs="+",
        help="you can specify a sequence of queries to process them overall",
    )
    query_file_group.add_argument(
        "--query_from_file",
        dest="query",
        type=EncodedFileType("r", encoding="utf-8"),
        # default=TextIOWrapper(sys.stdin.buffer, encoding='utf-8'),
        help="query file to get queries for inverted index",
    )
    query_parser.set_defaults(callback=callback_query)


def main():
    """
    Starter of the pipeline
    """
    parser = ArgumentParser(
        description="Inverted Index CLI is need to load, build,"
                    "process query inverted index"
    )
    setup_subparsers(parser)
    arguments = parser.parse_args()
    arguments.callback(arguments)


if __name__ == "__main__":
    main()
